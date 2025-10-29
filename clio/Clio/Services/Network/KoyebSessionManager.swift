import Foundation
import OSLog

/// Centralized session manager for Koyeb HTTP/2 connections
/// Ensures all Koyeb requests (LLM proxy, keep-alive, etc.) use the same URLSession
/// for proper connection reuse and to avoid the 1200-1500ms handshake overhead
final class KoyebSessionManager {
    static let shared = KoyebSessionManager()
    
    private let logger = Logger(subsystem: "com.cliovoice.clio", category: "KoyebSessionManager")
    private var _session: URLSession?
    private let sessionLock = NSLock()
    private weak var taskDelegate: URLSessionTaskDelegate?
    
    private init() {
        logger.notice("🚀 [KOYEB-SESSION] Initialized centralized session manager")
    }
    
    /// Set the task delegate for detailed network timing metrics
    /// Should be called by AIEnhancementService to enable URLSessionTaskDelegate callbacks
    func setTaskDelegate(_ delegate: URLSessionTaskDelegate?) {
        sessionLock.lock()
        defer { sessionLock.unlock() }
        
        // If delegate changes and we have an existing session, invalidate it to create new one with delegate
        if taskDelegate !== delegate && _session != nil {
            logger.notice("🔧 [KOYEB-SESSION] Delegate changed - will recreate session with new delegate")
            _session?.invalidateAndCancel()
            _session = nil
        }
        
        taskDelegate = delegate
    }
    
    /// Get the shared Koyeb session, creating it if needed
    /// This ensures ALL Koyeb communication uses the exact same URLSession instance
    var session: URLSession {
        sessionLock.lock()
        defer { sessionLock.unlock() }
        
        if let existingSession = _session {
            return existingSession
        }
        
        // Create Koyeb-optimized configuration with aggressive HTTP/3 disabling
        let config = createKoyebConfiguration()
        let newSession = URLSession(configuration: config, delegate: taskDelegate, delegateQueue: nil)
        _session = newSession
        
        let delegateInfo = taskDelegate != nil ? "with URLSessionTaskDelegate" : "without delegate"
        logger.notice("🆕 [KOYEB-SESSION] Created new persistent HTTP/2 session \(delegateInfo)")
        logger.notice("📍 [KOYEB-SESSION] Session object: \(String(describing: Unmanaged.passUnretained(newSession).toOpaque()))")
        
        return newSession
    }
    
    /// Force invalidate the current session (only for error recovery)
    func invalidateSession() {
        sessionLock.lock()
        defer { sessionLock.unlock() }
        
        if let session = _session {
            logger.warning("🔧 [KOYEB-SESSION] Invalidating corrupted session")
            session.invalidateAndCancel()
            _session = nil
        }
    }
    
    /// Create Koyeb-optimized configuration with HTTP/3 support
    private func createKoyebConfiguration() -> URLSessionConfiguration {
        // Use the factory to get HTTP/3 enabled configuration
        return URLSessionFactory.createKoyebConfiguration()
    }
    
    /// Debug helper to verify session identity
    func logSessionIdentity(context: String) {
        sessionLock.lock()
        defer { sessionLock.unlock() }
        
        if let session = _session {
            logger.notice("🔍 [KOYEB-SESSION] \(context) - Session: \(String(describing: Unmanaged.passUnretained(session).toOpaque()))")
        } else {
            logger.notice("🔍 [KOYEB-SESSION] \(context) - No session exists")
        }
    }
}

