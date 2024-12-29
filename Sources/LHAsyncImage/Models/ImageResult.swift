//
//  ImageResult.swift
//  LHAsyncImage
//
//  Created by Luiz Diniz Hammerli on 28/12/24.
//

import Foundation

enum ImageResult: Equatable {
    case cached(Data)
    case remote(Data)
}
