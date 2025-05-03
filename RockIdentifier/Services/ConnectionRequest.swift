// Rock Identifier: Crystal ID
// Muoyo Okome
//

import Foundation
import Combine

class ConnectionRequest: ObservableObject {
    @Published var isLoading: Bool = false
    var cancellable: AnyCancellable?

    func fetchData(_ url: String?, parameters: [String: String], completion: @escaping (Data?, String?) -> Void) {
        guard let urlString = url, let requestUrl = URL(string: urlString) else {
            completion(nil, "Invalid URL")
            return
        }

        // Setup connection
        var request = URLRequest(url: requestUrl)
        request.timeoutInterval = 180 // Increased timeout to 3 minutes
        request.setValue("close", forHTTPHeaderField: "Connection")

        // Prepare a POST request
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let postString = parameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = postString.data(using: .utf8)
        
        isLoading = true
        
        print("==> fetching \(requestUrl.absoluteString)")
        
        let customQueue = DispatchQueue(label: "com.rockidentifier.ConnectionRequest")
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .timeout(180, scheduler: customQueue) // 180 seconds timeout (3 minutes)
            .receive(on: customQueue)
            .sink { completionStatus in
                self.isLoading = false
                switch completionStatus {
                case .failure(let error):
                    completion(nil, error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { data, _ in
                DispatchQueue.global().async {
                    completion(data, nil)
                }
            }
    }

    deinit {
        cancellable?.cancel()
    }
}
