//
//  ImageFeatchableSpy.swift
//  LHAsyncImage
//
//  Created by Luiz Diniz Hammerli on 29/12/24.
//

import Foundation

@testable import LHAsyncImage

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
