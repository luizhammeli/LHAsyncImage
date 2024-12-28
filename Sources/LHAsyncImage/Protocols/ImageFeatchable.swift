//
//  ImageFeatchable.swift
//  LHAsyncImage
//
//  Created by Luiz Diniz Hammerli on 23/12/24.
//

import Foundation

protocol ImageFeatchable {
    func fetch(url: URL) async throws -> Data
}
