import Foundation

public enum RecordingEngineError: Error, Identifiable, Equatable {
    case accessDenied
    case invalidModelFile
    case modelDownloadFailed
    case modelDeletionFailed
    case modelLoadFailed
    case transcriptionFailed
    case unzipFailed

    public var id: String { String(describing: self) }
}

extension RecordingEngineError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .accessDenied:
            return NSLocalizedString("Access to this model is restricted. Upgrade your plan to continue.", comment: "Model access denied")
        case .invalidModelFile:
            return NSLocalizedString("The downloaded model file appears to be corrupt. Please remove it and try downloading again.", comment: "Invalid model file")
        case .modelDownloadFailed:
            return NSLocalizedString("We couldn't finish downloading the model. Check your connection and try again.", comment: "Model download failed")
        case .modelDeletionFailed:
            return NSLocalizedString("The model could not be removed from disk. Check file permissions and try again.", comment: "Model deletion failed")
        case .modelLoadFailed:
            return NSLocalizedString("Clio couldn't load the selected model. Please re-download or choose a different one.", comment: "Model load failed")
        case .transcriptionFailed:
            return NSLocalizedString("Something went wrong while transcribing this audio. Please try again.", comment: "Transcription failed")
        case .unzipFailed:
            return NSLocalizedString("The Core ML package failed to unzip correctly. Try downloading the model again.", comment: "Core ML unzip failed")
        }
    }
}
