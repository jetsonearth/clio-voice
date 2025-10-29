  import Foundation

  /// A gate that manages async connection attempts, ensuring only one continuation is active at a time
  /// and preventing race conditions during WebSocket connection establishment.
  ///
  /// Thread-safe gate using a private serial queue to avoid actor/global-actor init issues.
  public final class ConnectionGate {
      private var continuation: CheckedContinuation<Void, Error>?
      private var attemptId: Int = 0
      private let queue = DispatchQueue(label: "com.cliovoice.clio.connection-gate")

      /// Install a new continuation for a connection attempt, canceling any pending one
      public func install(_ continuation: CheckedContinuation<Void, Error>, attemptId: Int) {
          queue.sync {
              if let existing = self.continuation {
                  existing.resume(throwing: ConnectionGateError.superseded)
              }
              self.continuation = continuation
              self.attemptId = attemptId
          }
      }

      /// Resume with success for a specific attempt
      public func resumeSuccess(for attemptId: Int) {
          queue.sync {
              guard let cont = self.continuation, self.attemptId == attemptId else { return }
              self.continuation = nil
              cont.resume()
          }
      }

      /// Resume with failure for a specific attempt
      public func resumeFailure(_ error: Error, for attemptId: Int) {
          queue.sync {
              guard let cont = self.continuation, self.attemptId == attemptId else { return }
              self.continuation = nil
              cont.resume(throwing: error)
          }
      }

      /// Cancel any pending continuation
      public func cancelIfPending(_ error: Error) {
          queue.sync {
              guard let cont = self.continuation else { return }
              self.continuation = nil
              cont.resume(throwing: error)
          }
      }
  }

  // Errors specific to ConnectionGate operations
  public enum ConnectionGateError: LocalizedError {
      case superseded
      case cancelled

      public var errorDescription: String? {
          switch self {
          case .superseded:
              return "Connection attempt was superseded by a newer attempt"
          case .cancelled:
              return "Connection attempt was cancelled"
          }
      }
  }
