// Rock Identifier: Crystal ID - Enhanced Connection with Retry Logic
// Muoyo Okome
//

import Foundation
import Combine
import Network

class ConnectionRequest: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var connectionStatus: NWPath.Status = .satisfied
    
    private var cancellable: AnyCancellable?
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    // Retry configuration
    private let maxRetries = 3
    private let baseDelay: TimeInterval = 1.0
    private let timeoutInterval: TimeInterval = 45.0 // Reduced from 180 to 45 seconds
    
    init() {
        startNetworkMonitoring()
    }
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.connectionStatus = path.status
                print("Network status: \(path.status)")
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    func fetchData(_ url: String?, parameters: [String: String], completion: @escaping (Data?, String?) -> Void) {
        guard let urlString = url, let requestUrl = URL(string: urlString) else {
            completion(nil, "Invalid URL")
            return
        }
        
        // Check network connectivity first
        guard connectionStatus == .satisfied else {
            completion(nil, "No internet connection available. Please check your connection and try again.")
            return
        }
        
        isLoading = true
        
        // Start retry mechanism
        performRequestWithRetry(url: requestUrl, parameters: parameters, retryCount: 0) { [weak self] data, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                completion(data, error)
            }
        }
    }
    
    private func performRequestWithRetry(url: URL, parameters: [String: String], retryCount: Int, completion: @escaping (Data?, String?) -> Void) {
        
        print("==> Attempt \(retryCount + 1)/\(maxRetries + 1) - fetching \(url.absoluteString)")
        
        // Create request with optimized settings for iOS 18.5
        var request = URLRequest(url: url)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("RockIdentifier/1.0", forHTTPHeaderField: "User-Agent")
        
        // Prepare POST body
        let postString = parameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = postString.data(using: .utf8)
        
        // Configure URLSession for better reliability
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutInterval
        config.timeoutIntervalForResource = timeoutInterval * 2
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        config.httpMaximumConnectionsPerHost = 1
        
        let session = URLSession(configuration: config)
        
        let customQueue = DispatchQueue(label: "com.rockidentifier.ConnectionRequest.\(retryCount)")
        
        cancellable = session.dataTaskPublisher(for: request)
            .timeout(.seconds(Int(timeoutInterval)), scheduler: DispatchQueue.main, options: nil, customError: {
                URLError(.timedOut)
            })
            .receive(on: customQueue)
            .sink(
                receiveCompletion: { [weak self] completionStatus in
                    switch completionStatus {
                    case .failure(let error):
                        self?.handleRequestError(error, url: url, parameters: parameters, retryCount: retryCount, completion: completion)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] data, response in
                    guard let self = self else { return }
                    // Check HTTP status code
                    if let httpResponse = response as? HTTPURLResponse {
                        print("HTTP Status: \(httpResponse.statusCode)")
                        
                        if httpResponse.statusCode == 200 {
                            print("✅ Request successful after \(retryCount + 1) attempt(s)")
                            completion(data, nil)
                        } else {
                            let errorMsg = "Server error: HTTP \(httpResponse.statusCode)"
                            print("❌ \(errorMsg)")
                            
                            // Retry on server errors (500-599) but not client errors (400-499)
                            if httpResponse.statusCode >= 500 && retryCount < self.maxRetries {
                                self.scheduleRetry(url: url, parameters: parameters, retryCount: retryCount, completion: completion, error: errorMsg)
                            } else {
                                completion(nil, errorMsg)
                            }
                        }
                    } else {
                        completion(data, nil) // Fallback for non-HTTP responses
                    }
                }
            )
    }
    
    private func handleRequestError(_ error: Error, url: URL, parameters: [String: String], retryCount: Int, completion: @escaping (Data?, String?) -> Void) {
        
        let nsError = error as NSError
        print("❌ Request failed: \(error.localizedDescription) (Code: \(nsError.code))")
        
        // Determine if we should retry based on error type
        let shouldRetry = shouldRetryForError(nsError) && retryCount < maxRetries
        
        if shouldRetry {
            let errorDescription = friendlyErrorDescription(for: nsError)
            print("🔄 Will retry after delay. Reason: \(errorDescription)")
            scheduleRetry(url: url, parameters: parameters, retryCount: retryCount, completion: completion, error: errorDescription)
        } else {
            // Final failure - provide user-friendly error message
            let finalError = finalErrorMessage(for: nsError, retryCount: retryCount)
            print("💥 Final failure: \(finalError)")
            completion(nil, finalError)
        }
    }
    
    private func shouldRetryForError(_ error: NSError) -> Bool {
        switch error.code {
        case NSURLErrorTimedOut,
             NSURLErrorCannotConnectToHost,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorDNSLookupFailed,
             NSURLErrorResourceUnavailable,
             NSURLErrorInternationalRoamingOff,
             NSURLErrorCallIsActive,
             NSURLErrorDataNotAllowed:
            return true
        default:
            return false
        }
    }
    
    private func scheduleRetry(url: URL, parameters: [String: String], retryCount: Int, completion: @escaping (Data?, String?) -> Void, error: String) {
        
        // Calculate exponential backoff delay
        let delay = baseDelay * pow(2.0, Double(retryCount))
        let jitteredDelay = delay + Double.random(in: 0...1) // Add jitter to avoid thundering herd
        
        print("⏱️ Retrying in \(String(format: "%.1f", jitteredDelay)) seconds...")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + jitteredDelay) { [weak self] in
            // Check network status before retry
            if self?.connectionStatus == .satisfied {
                self?.performRequestWithRetry(url: url, parameters: parameters, retryCount: retryCount + 1, completion: completion)
            } else {
                completion(nil, "Network connection lost. Please check your internet connection and try again.")
            }
        }
    }
    
    private func friendlyErrorDescription(for error: NSError) -> String {
        switch error.code {
        case NSURLErrorTimedOut:
            return "Connection timed out"
        case NSURLErrorCannotConnectToHost:
            return "Cannot connect to server"
        case NSURLErrorNetworkConnectionLost:
            return "Network connection lost"
        case NSURLErrorNotConnectedToInternet:
            return "No internet connection"
        case NSURLErrorDNSLookupFailed:
            return "Server lookup failed"
        case NSURLErrorResourceUnavailable:
            return "Server temporarily unavailable"
        default:
            return error.localizedDescription
        }
    }
    
    private func finalErrorMessage(for error: NSError, retryCount: Int) -> String {
        let baseMessage: String
        
        switch error.code {
        case NSURLErrorTimedOut:
            baseMessage = "Connection timed out after \(retryCount + 1) attempts. The server may be experiencing high load."
        case NSURLErrorCannotConnectToHost:
            baseMessage = "Unable to connect to the identification server. Please try again in a few moments."
        case NSURLErrorNetworkConnectionLost:
            baseMessage = "Network connection was lost during identification. Please check your connection and try again."
        case NSURLErrorNotConnectedToInternet:
            baseMessage = "No internet connection available. Please connect to WiFi or cellular data and try again."
        case NSURLErrorDNSLookupFailed:
            baseMessage = "Server lookup failed. Please check your internet connection and try again."
        default:
            baseMessage = "Network error occurred. Please try again."
        }
        
        return baseMessage
    }
    
    func cancelRequest() {
        cancellable?.cancel()
        isLoading = false
        print("❌ Request cancelled")
    }
    
    deinit {
        cancellable?.cancel()
        monitor.cancel()
    }
}
