// Rock Identifier: Crystal ID - Simplified Enhanced Connection
// Muoyo Okome
//

import Foundation
import Combine
import Network

protocol ConnectionRequestDelegate: AnyObject {
    func connectionDidStartRetry(attempt: Int, maxAttempts: Int)
    func connectionDidCompleteAllRetries()
}

class EnhancedConnectionRequest: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var connectionStatus: NWPath.Status = .satisfied
    @Published var currentRetryAttempt: Int = 0
    
    weak var delegate: ConnectionRequestDelegate?
    
    private var cancellable: AnyCancellable?
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    
    // Retry configuration optimized for iOS 18.5
    private let maxRetries = 3
    private let baseDelay: TimeInterval = 2.0
    private let timeoutInterval: TimeInterval = 30.0 // Shorter timeout for better reliability
    
    init() {
        startNetworkMonitoring()
    }
    
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.connectionStatus = path.status
                print("📶 Network status: \(path.status)")
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    func fetchDataWithRetry(_ url: String?, parameters: [String: String], completion: @escaping (Data?, String?) -> Void) {
        guard let urlString = url, let requestUrl = URL(string: urlString) else {
            completion(nil, "Invalid URL configuration")
            return
        }
        
        // Check network connectivity first
        guard connectionStatus == .satisfied else {
            completion(nil, "No internet connection. Please check your connection and try again.")
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.currentRetryAttempt = 0
        }
        
        // Start retry mechanism
        performRequestWithRetry(url: requestUrl, parameters: parameters, retryCount: 0) { [weak self] data, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.currentRetryAttempt = 0
                self?.delegate?.connectionDidCompleteAllRetries()
                completion(data, error)
            }
        }
    }
    
    private func performRequestWithRetry(url: URL, parameters: [String: String], retryCount: Int, completion: @escaping (Data?, String?) -> Void) {
        
        print("🔄 Attempt \(retryCount + 1)/\(maxRetries + 1) - fetching \(url.absoluteString)")
        
        // Update retry state for UI
        DispatchQueue.main.async {
            self.currentRetryAttempt = retryCount
            if retryCount > 0 {
                self.delegate?.connectionDidStartRetry(attempt: retryCount, maxAttempts: self.maxRetries)
            }
        }
        
        // Create optimized request for iOS 18.5
        var request = URLRequest(url: url)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("RockIdentifier/1.0 iOS/18.5", forHTTPHeaderField: "User-Agent")
        request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        request.addValue("30", forHTTPHeaderField: "Keep-Alive")
        
        // Prepare POST body
        let postString = parameters.map { 
            "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")" 
        }.joined(separator: "&")
        request.httpBody = postString.data(using: .utf8)
        
        // Configure URLSession with iOS 18.5 optimized settings
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutInterval
        config.timeoutIntervalForResource = timeoutInterval * 1.5
        config.waitsForConnectivity = false
        config.allowsCellularAccess = true
        config.allowsConstrainedNetworkAccess = true
        config.allowsExpensiveNetworkAccess = true
        config.httpMaximumConnectionsPerHost = 1
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        let session = URLSession(configuration: config)
        
        // Use a simpler approach without complex Combine timeout
        cancellable = session.dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
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
                    self?.handleSuccessfulResponse(data: data, response: response, url: url, parameters: parameters, retryCount: retryCount, completion: completion)
                }
            )
    }
    
    private func handleSuccessfulResponse(data: Data, response: URLResponse, url: URL, parameters: [String: String], retryCount: Int, completion: @escaping (Data?, String?) -> Void) {
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200...299:
                print("✅ Request successful after \(retryCount + 1) attempt(s)")
                completion(data, nil)
            case 500...599:
                // Server error - retry if possible
                let errorMsg = "Server temporarily unavailable (HTTP \(httpResponse.statusCode))"
                print("⚠️ Server error: \(errorMsg)")
                
                if retryCount < maxRetries {
                    scheduleRetry(url: url, parameters: parameters, retryCount: retryCount, completion: completion, error: errorMsg)
                } else {
                    completion(nil, "Server is temporarily unavailable. Please try again later.")
                }
            case 400...499:
                // Client error - don't retry
                let errorMsg = "Request error (HTTP \(httpResponse.statusCode))"
                print("❌ Client error: \(errorMsg)")
                completion(nil, "There was a problem with your request. Please try again.")
            default:
                completion(nil, "Unexpected server response. Please try again.")
            }
        } else {
            // Non-HTTP response - assume success
            completion(data, nil)
        }
    }
    
    private func handleRequestError(_ error: Error, url: URL, parameters: [String: String], retryCount: Int, completion: @escaping (Data?, String?) -> Void) {
        
        let nsError = error as NSError
        let errorDescription = friendlyErrorDescription(for: nsError)
        print("❌ Request failed: \(errorDescription) (Code: \(nsError.code))")
        
        // Log specific details for iOS 18.5 debugging
        if #available(iOS 18.0, *) {
            print("🔍 iOS 18.5 Error Details: Domain=\(nsError.domain), Code=\(nsError.code), UserInfo=\(nsError.userInfo)")
        }
        
        // Determine if we should retry based on error type
        let shouldRetry = shouldRetryForError(nsError) && retryCount < maxRetries
        
        if shouldRetry {
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
        // More specific retry logic for iOS 18.5
        switch error.code {
        case NSURLErrorTimedOut,
             NSURLErrorCannotConnectToHost,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorNotConnectedToInternet,
             NSURLErrorDNSLookupFailed,
             NSURLErrorResourceUnavailable,
             NSURLErrorCannotFindHost,
             NSURLErrorSecureConnectionFailed:
            return true
        default:
            // Log unknown errors for debugging
            print("🔍 Unknown error code \(error.code): \(error.localizedDescription)")
            return false
        }
    }
    
    private func scheduleRetry(url: URL, parameters: [String: String], retryCount: Int, completion: @escaping (Data?, String?) -> Void, error: String) {
        
        // Calculate exponential backoff with jitter
        let delay = baseDelay * pow(2.0, Double(retryCount))
        let jitteredDelay = delay + Double.random(in: 0...1)
        
        print("⏱️ Retrying in \(String(format: "%.1f", jitteredDelay)) seconds...")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + jitteredDelay) { [weak self] in
            // Double-check network status before retry
            guard self?.connectionStatus == .satisfied else {
                completion(nil, "Network connection lost. Please check your internet connection and try again.")
                return
            }
            
            self?.performRequestWithRetry(url: url, parameters: parameters, retryCount: retryCount + 1, completion: completion)
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
        case NSURLErrorDNSLookupFailed, NSURLErrorCannotFindHost:
            return "Server lookup failed"
        case NSURLErrorResourceUnavailable:
            return "Server temporarily unavailable"
        case NSURLErrorSecureConnectionFailed:
            return "Secure connection failed"
        default:
            return error.localizedDescription
        }
    }
    
    private func finalErrorMessage(for error: NSError, retryCount: Int) -> String {
        switch error.code {
        case NSURLErrorTimedOut:
            return "Connection timed out after \(retryCount + 1) attempts. Please try again when you have a stronger connection."
        case NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost:
            return "Unable to connect to the server. Please check your internet connection and try again."
        case NSURLErrorNetworkConnectionLost:
            return "Your connection was interrupted. Please check your internet connection and try again."
        case NSURLErrorNotConnectedToInternet:
            return "No internet connection. Please connect to WiFi or cellular data and try again."
        case NSURLErrorDNSLookupFailed:
            return "Network error occurred. Please check your connection and try again."
        case NSURLErrorSecureConnectionFailed:
            return "Secure connection failed. Please try again."
        default:
            return "Network error occurred after \(retryCount + 1) attempts. Please try again."
        }
    }
    
    func cancelRequest() {
        cancellable?.cancel()
        isLoading = false
        currentRetryAttempt = 0
    }
    
    deinit {
        cancellable?.cancel()
        monitor.cancel()
    }
}
