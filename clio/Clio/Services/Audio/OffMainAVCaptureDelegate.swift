//
//  OffMainAVCaptureDelegate.swift
//  Clio
//
//  A lightweight AVCaptureAudioDataOutputSampleBufferDelegate that performs
//  CMSampleBuffer -> AVAudioPCMBuffer conversion off the main actor and forwards
//  the result via a callback. Used when AppConfig.offMainAVCaptureDelegateEnabled is true.
//

import Foundation
import AVFoundation

final class OffMainAVCaptureDelegate: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    typealias PCMForwarder = (AVAudioPCMBuffer, AVAudioTime) -> Void

    private let forward: PCMForwarder

    init(forward: @escaping PCMForwarder) {
        self.forward = forward
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
        guard let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc) else { return }

        let channels = AVAudioChannelCount(asbd.pointee.mChannelsPerFrame)
        let sampleRate = Double(asbd.pointee.mSampleRate)
        let commonFormat: AVAudioCommonFormat = .pcmFormatFloat32
        guard let format = AVAudioFormat(commonFormat: commonFormat, sampleRate: sampleRate, channels: channels, interleaved: false) else { return }

        let numSamples = CMSampleBufferGetNumSamples(sampleBuffer)
        guard numSamples > 0 else { return }

        // Extract AudioBufferList safely: first query required size, then allocate
        var blockBuffer: CMBlockBuffer? = nil
        var sizeNeeded: Int = 0
        var status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            bufferListSizeNeededOut: &sizeNeeded,
            bufferListOut: nil,
            bufferListSize: 0,
            blockBufferAllocator: kCFAllocatorDefault,
            blockBufferMemoryAllocator: kCFAllocatorDefault,
            flags: kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
            blockBufferOut: &blockBuffer
        )
        if status != noErr || sizeNeeded <= 0 { return }

        let rawPtr = UnsafeMutableRawPointer.allocate(byteCount: sizeNeeded, alignment: MemoryLayout<AudioBufferList>.alignment)
        defer { rawPtr.deallocate() }
        let ablPtr = rawPtr.bindMemory(to: AudioBufferList.self, capacity: 1)
        status = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(
            sampleBuffer,
            bufferListSizeNeededOut: nil,
            bufferListOut: ablPtr,
            bufferListSize: sizeNeeded,
            blockBufferAllocator: kCFAllocatorDefault,
            blockBufferMemoryAllocator: kCFAllocatorDefault,
            flags: kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
            blockBufferOut: &blockBuffer
        )
        if status != noErr { return }

        let audioBufferListPointer = UnsafeMutableAudioBufferListPointer(ablPtr)
        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(numSamples)) else { return }
        pcmBuffer.frameLength = AVAudioFrameCount(numSamples)

        // Copy deinterleaved float data per channel if available
        for (channelIndex, audioBuffer) in audioBufferListPointer.enumerated() {
            let src = audioBuffer.mData?.assumingMemoryBound(to: Float.self)
            let dst = pcmBuffer.floatChannelData?[min(channelIndex, Int(pcmBuffer.format.channelCount) - 1)]
            if let src = src, let dst = dst {
                let count = min(Int(audioBuffer.mDataByteSize) / MemoryLayout<Float>.size, Int(numSamples))
                dst.assign(from: src, count: count)
            }
        }

        let when = AVAudioTime(hostTime: mach_absolute_time())
        forward(pcmBuffer, when)
    }
}

