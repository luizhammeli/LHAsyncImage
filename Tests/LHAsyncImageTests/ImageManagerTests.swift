//
//  ImageManagerTests.swift
//  LHAsyncImage
//
//  Created by Luiz Diniz Hammerli on 28/12/24.
//

import XCTest

@testable import LHAsyncImage

final class ImageManagerTests: XCTestCase {
    func test_fetch_shouldReturnFromThePrimarySource() async {
        // Arrange
        let expectedData = "value".data(using: .utf8)!
        let fakeURL = URL(string: "https://test.com")!
        let (sut, primarySpy, secondarySpy) = makeSUT(url: fakeURL, expectedData: expectedData)

        // Act
        let receivedValue = try? await sut.fetch(url: fakeURL)

        // Assert
        XCTAssertEqual(receivedValue, .cached(expectedData))
        XCTAssertEqual(primarySpy.actions, [.fetch(fakeURL)])
        XCTAssertTrue(secondarySpy.actions.isEmpty)
    }

    func test_fetch_shouldReturnFromTheSecondarySource() async {
        // Arrange
        let expectedData = "value".data(using: .utf8)!
        let fakeURL = URL(string: "https://test.com")!
        let (sut, primarySpy, secondarySpy) = makeSUT(
            url: fakeURL,
            expectedData: expectedData,
            source: .secondary
        )

        // Act
        let receivedValue = try? await sut.fetch(url: fakeURL)

        // Assert
        XCTAssertEqual(receivedValue, .remote(expectedData))
        XCTAssertEqual(primarySpy.actions, [.fetch(fakeURL)])
        XCTAssertEqual(secondarySpy.actions, [.fetch(fakeURL)])
    }

    func test_fetch_shouldFailure() async {
        // Arrange
        let expectedData = "value".data(using: .utf8)!
        let fakeURL = URL(string: "https://test.com")!
        let (sut, _, _) = makeSUT(
            url: fakeURL,
            expectedData: expectedData,
            source: .error
        )

        // Act
        do {
            _ = try await sut.fetch(url: fakeURL)
            XCTFail()
        } catch {
            // Assert
            XCTAssertEqual(error as? ImageError, .imageNotFound)
        }
    }
}

private extension ImageManagerTests {
    enum DataSource {
        case primary
        case secondary
        case error
    }

    func makeSUT(
        url: URL,
        expectedData: Data,
        source: DataSource = .primary
    ) -> (sut: ImageManager, primary: ImageFeatchableSpy, secondary: ImageFeatchableSpy) {
        let primaryCacheSpy = ImageFeatchableSpy(result: source == .primary ? expectedData : nil)
        let secondaryCacheSpy = ImageFeatchableSpy(result: source == .secondary ? expectedData : nil)
        let sut = ImageManager(primary: primaryCacheSpy, secondary: secondaryCacheSpy)

        return (sut, primaryCacheSpy, secondaryCacheSpy)
    }
}

final class ImageFeatchableSpy: ImageFeatchable {
    enum Action: Equatable {
        case fetch(URL)
    }

    private(set) var actions: [Action] = []
    private var result: Data?

    init(result: Data? = nil) {
        self.result = result
    }

    func fetch(url: URL) async throws -> Data {
        actions.append(.fetch(url))
        guard let result else { throw ImageError.imageNotFound }
        return result
    }
}
