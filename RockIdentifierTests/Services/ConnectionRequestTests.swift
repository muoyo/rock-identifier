// Rock Identifier: Crystal ID
// Muoyo Okome
//

import XCTest
@testable import RockIdentifier

class ConnectionRequestTests: XCTestCase {
    var connectionRequest: ConnectionRequest!
    
    override func setUp() {
        super.setUp()
        connectionRequest = ConnectionRequest()
    }
    
    override func tearDown() {
        connectionRequest = nil
        super.tearDown()
    }
    
    func testParameterEncoding() {
        // Test that the connection request properly encodes parameters
        // We'll use our knowledge of how the ConnectionRequest implementation works
        // to verify that parameters are encoded correctly
        
        // Create sample parameters
        let parameters = [
            "name": "Test Rock",
            "category": "Test Category",
            "special+character": "test@value&with-chars"
        ]
        
        // Create expectations
        let expectation = self.expectation(description: "Parameter Encoding Test")
        
        // Use a mock URL that doesn't actually connect
        let mockUrl = "https://example.com/test"
        
        // Implement a mock URL session for testing
        class MockURLSession: URLSessionProtocol {
            var lastRequest: URLRequest?
            var completionHandler: ((Data?, String) -> Void)?
            
            func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
                self.lastRequest = request
                
                // Create a mock data task that captures the request
                class MockDataTask: URLSessionDataTaskProtocol {
                    var resumeWasCalled = false
                    
                    func resume() {
                        resumeWasCalled = true
                    }
                }
                
                return MockDataTask()
            }
        }
        
        // Create the mock session
        let mockSession = MockURLSession()
        connectionRequest.urlSession = mockSession
        
        // Make the request
        connectionRequest.fetchData(mockUrl, parameters: parameters) { _, _ in
            // This won't actually be called in our mock
            expectation.fulfill()
        }
        
        // Verify the request was properly formed
        if let request = mockSession.lastRequest, let httpBody = request.httpBody {
            let bodyString = String(data: httpBody, encoding: .utf8) ?? ""
            
            // Verify content type header
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")
            
            // Verify parameters were encoded
            XCTAssertTrue(bodyString.contains("name=Test%20Rock"))
            XCTAssertTrue(bodyString.contains("category=Test%20Category"))
            XCTAssertTrue(bodyString.contains("special%2Bcharacter=test%40value%26with-chars"))
            
            // Since we're using a mock, manually fulfill the expectation
            expectation.fulfill()
        } else {
            XCTFail("Request should have HTTP body")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Test HTTP method is POST
    func testHTTPMethod() {
        // Create expectations
        let expectation = self.expectation(description: "HTTP Method Test")
        
        // Use a mock URL that doesn't actually connect
        let mockUrl = "https://example.com/test"
        
        // Implement a mock URL session
        class MockURLSession: URLSessionProtocol {
            var lastRequest: URLRequest?
            
            func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
                self.lastRequest = request
                
                class MockDataTask: URLSessionDataTaskProtocol {
                    func resume() {}
                }
                
                return MockDataTask()
            }
        }
        
        // Create the mock session
        let mockSession = MockURLSession()
        connectionRequest.urlSession = mockSession
        
        // Make the request
        connectionRequest.fetchData(mockUrl, parameters: [:]) { _, _ in
            expectation.fulfill()
        }
        
        // Verify the request was properly formed
        if let request = mockSession.lastRequest {
            XCTAssertEqual(request.httpMethod, "POST")
            
            // Since we're using a mock, manually fulfill the expectation
            expectation.fulfill()
        } else {
            XCTFail("Request should have been created")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

// Add protocol extensions to make ConnectionRequest testable

// Assuming these protocols are defined in ConnectionRequest.swift
// If not, you'll need to add them to the ConnectionRequest class
protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume()
}

// Extensions to make URLSession and URLSessionDataTask conform to the protocols
extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

// Extension to ConnectionRequest to allow for dependency injection
extension ConnectionRequest {
    var urlSession: URLSessionProtocol {
        get {
            if let session = objc_getAssociatedObject(self, &AssociatedKeys.urlSessionKey) as? URLSessionProtocol {
                return session
            }
            return URLSession.shared
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.urlSessionKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

// Associated keys for runtime property association
private struct AssociatedKeys {
    static var urlSessionKey = "urlSessionKey"
}
