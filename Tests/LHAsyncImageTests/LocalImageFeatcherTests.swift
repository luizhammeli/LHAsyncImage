//
//  LocalImageFeatcherTests.swift
//  LHAsyncImage
//
//  Created by Luiz Diniz Hammerli on 08/12/24.
//

import XCTest
@testable import LHAsyncImage

final class LocalImageFeatcherTests: XCTestCase {
    func test_fetch_shouldThrowImageNotFoundException() async {
        // Arange
        let sut = LocalImageFeatcher()

        // Act
        do {
            _ = try await sut.fetch(url: URL(string: "https//test.com")!)
            XCTFail("Expected ImageNotFoundException")
        } catch {
            // Assert
            XCTAssertEqual(error as? ImageError, .imageNotFound)
        }
    }

    func test_fetch_shouldCompleteWithSuccess() async {
        // Arange
        let fakeURL = URL(string: "https//test.com")!
        let fakeData = "test-image".data(using: .utf8)!
        let fakeCache = NSCache<NSString, NSData>()
        let sut = LocalImageFeatcher(cache: fakeCache)

        // Act
        fakeCache.setObject(fakeData as NSData, forKey: fakeURL.description as NSString)
        let value = try? await sut.fetch(url: fakeURL)

        // Assert
        XCTAssertEqual(value, fakeData)
    }
}
