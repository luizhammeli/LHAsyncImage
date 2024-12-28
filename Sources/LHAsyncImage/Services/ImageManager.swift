//
//  ImageManager.swift
//  LHAsyncImage
//
//  Created by Luiz Diniz Hammerli on 28/12/24.
//

import Foundation

final class ImageManager: ImageManageable {
    private let primary: ImageFeatchable
    private let secondary: ImageFeatchable
    private let cache: NSCache<NSString, NSData>

    init(
        primary: ImageFeatchable = LocalImageFeatcher(),
        secondary: ImageFeatchable = RemoteImageFeatcher(),
        cache: NSCache<NSString, NSData> = LocalImageFeatcher.defaultCache
    ) {
        self.primary = primary
        self.secondary = secondary
        self.cache = cache
    }

    func fetch(url: URL) async throws -> ImageResult {
        if let data = try? await primary.fetch(url: url) {
            return .cached(data as Data)
        } else {
            let data = try await secondary.fetch(url: url)
            cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
            return .remote(data)
        }
    }
}
