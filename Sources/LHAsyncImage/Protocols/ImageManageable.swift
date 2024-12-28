//
//  ImageManageable.swift
//  LHAsyncImage
//
//  Created by Luiz Diniz Hammerli on 28/12/24.
//

import Foundation

protocol ImageManageable {
    func fetch(url: URL) async throws -> ImageResult
}
