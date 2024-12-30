//
//  ImageViewModel.swift
//  LHAsyncImage
//
//  Created by Luiz Diniz Hammerli on 29/12/24.
//

import SwiftUI


@MainActor
final class ImageViewModel: ObservableObject {
    nonisolated(unsafe) private let imageFeatcher: ImageManageable
    @Published var image: UIImage?

    init(imageFeatcher: ImageManageable = ImageManager()) {
        self.imageFeatcher = imageFeatcher
    }

    func fetchImage(with url: URL) async {
        if let imageData = try? await imageFeatcher.fetch(url: url) {
            if case .cached(let data) = imageData {
                image = UIImage(data: data)
            } else if case .remote(let data) = imageData {
                withAnimation { image = UIImage(data: data) }
            }
        }
    }
}
