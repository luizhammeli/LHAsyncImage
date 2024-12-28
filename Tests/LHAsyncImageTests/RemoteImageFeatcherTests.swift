//
//  RemoteImageFeatcherTests.swift
//  LHAsyncImage
//
//  Created by Luiz Diniz Hammerli on 08/12/24.
//

import XCTest

@testable import LHAsyncImage

final class RemoteImageFeatcherTests: XCTestCase {
    private var sut: RemoteImageFeatcher?

    override class func setUp() {
        super.setUp()
    }

    override func setUp() {
        super.setUp()
        URLProtocolStub.startIntercepting()
        self.sut = RemoteImageFeatcher()
    }

    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopIntercepting()
    }

    func test_fetch_urlRequest() async {
        //Arrange
        var receivedRequest: URLRequest?
        let fakeURL = URL(string: "https://test.com")!
        URLProtocolStub.stub(.init(data: nil, response: URLResponse(), error: nil))
        URLProtocolStub.observeRequest { receivedRequest = $0 }

          // Act
        _ = try? await sut?.fetch(url: fakeURL)

        // Assert
        XCTAssertEqual(receivedRequest?.url, fakeURL)
    }

    func test_fetch_shouldThrownAnExpection() async {
        //Arrange
        var tasksCount: Int?
        let fakeError = NSError(domain: "test-error", code: 1)
        var receivedError: NSError?
        URLProtocolStub.stub(.init(data: nil, response: URLResponse(), error: fakeError))

        // Act
        do {
            _ = try await sut?.fetch(url: URL(string: "https://test.com")!)
        } catch {
            tasksCount = await sut?.tasks.count
            receivedError = error as NSError
        }

        // Assert
        XCTAssertEqual(receivedError?.domain, fakeError.domain)
        XCTAssertEqual(receivedError?.code, fakeError.code)
        XCTAssertEqual(tasksCount, 0)
    }

    func test_fetch_shouldThrownAnInvalidResponseExpection() async {
        //Arrange
        var receivedError: ImageError?
        let fakeResponse = makeFakeResponse(statusCode: 300)
        URLProtocolStub.stub(.init(data: nil, response: fakeResponse, error: nil))

        // Act
        do {
            _ = try await sut?.fetch(url: URL(string: "https://test.com")!)
        } catch {
            receivedError = error as? ImageError
        }

        // Assert
        XCTAssertEqual(receivedError, .invalidResponse)
    }

    func test_fetch_shouldThrownAnSuccessResponse() async {
        //Arrange
        let fakeResponse = makeFakeResponse(statusCode: 200)
        let expectedValue = "fake-data".data(using: .utf8)
        URLProtocolStub.stub(.init(data: expectedValue, response: fakeResponse, error: nil))

        // Act
        let receivedData = try? await sut?.fetch(url: URL(string: "https://test.com")!)

        // Assert
        XCTAssertEqual(receivedData, expectedValue)
    }
}

private extension RemoteImageFeatcherTests {
    func makeFakeResponse(statusCode: Int = 200) -> HTTPURLResponse {
        let url = URL(string: "https://test.com")!
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: [:])!
    }
}

struct Stub {
    let data: Data?
    let response: URLResponse?
    let error: Error?
}

class URLProtocolStub: URLProtocol {
    nonisolated(unsafe) private static var stub: Stub?
    nonisolated(unsafe) private static var requestObserver: ((URLRequest) -> Void)?

    static func startIntercepting() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    static func stopIntercepting() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let requestObserver = URLProtocolStub.requestObserver {
            requestObserver(request)
        }

        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        }

        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        URLProtocolStub.requestObserver = nil
    }

    static func observeRequest(with observer: @escaping (URLRequest) -> Void) {
        URLProtocolStub.requestObserver = observer
    }

    static func stub(_ stub: Stub) {
        URLProtocolStub.stub = stub
    }
}
