//
//  LocalImageFeatcher.swift
//  LHAsyncImage
//
//  Created by Luiz Diniz Hammerli on 23/12/24.
//

import Foundation

final class LocalImageFeatcher: ImageFeatchable {
    nonisolated(unsafe) static let defaultCache: NSCache<NSString, NSData> = .init()
    private let cache: NSCache<NSString, NSData>

    init(cache: NSCache<NSString, NSData> = LocalImageFeatcher.defaultCache) {
        self.cache = cache
    }

    func fetch(url: URL) async throws -> Data {
        guard let data = cache.object(forKey: NSString(string: url.absoluteString)) else {
            throw ImageError.imageNotFound
        }
        return data as Data
    }
}
