//
//  CustomAsyncImage.swift
//  AppStoreMock
//
//  Created by Luiz Diniz Hammerli on 30/11/24.
//

import SwiftUI

struct CustomAsyncImage<P: View>: View {
    private let url: URL
    @StateObject private var viewModel = ImageViewModel()
    @Binding var isLoaded: Bool
    @ViewBuilder private let placeholder: (() -> P)?

    init(
        url: URL,
        isLoaded: Binding<Bool>? = nil
    ) where P == Image {
        self.url = url
        self.placeholder = nil
        self._isLoaded = isLoaded ?? .constant(false)
    }

    init(
        url: URL,
        @ViewBuilder _ placeholder: @escaping (() -> P)
    ) {
        self.url = url
        self.placeholder = placeholder
        self._isLoaded = .constant(false)
    }

    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .opacity(viewModel.image != nil ? 1 : 0)
            } else if let placeholder {
                placeholder()
            }
        }.task {
            await viewModel.fetchImage(with: url)
            self.isLoaded = true
        }
    }
}

#Preview {
    let url = URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/ba/37/98/ba3798a7-ca27-7f6a-a021-1c6eed952db5/AppIcon-0-0-1x_U007emarketing-0-8-0-sRGB-85-220.png/512x512bb.jpg")!
    CustomAsyncImage(url: url)
        .scaledToFit()
        .frame(width: 220, height: 220)
}

#Preview("Placeholder") {
    let url = URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/ba/37/98/ba3798a7-ca27-7f6a-a021-1c6eed952db5/AppIcon-0-0-1x_U007emarketing-0-8-0-sRGB-85-220.png/512x512bb.jpg")!
    CustomAsyncImage(url: url) {
        Image("uber-eats", bundle: nil)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.red)
            .frame(width: 100, height: 100)
    }
    .scaledToFit()
    .frame(width: 220, height: 220)
}

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
                withAnimation {
                    image = UIImage(data: data)
                }
            }
        }
    }
}

enum ImageResult {
    case cached(Data)
    case remote(Data)
}

protocol ImageManageable {
    func fetch(url: URL) async throws -> ImageResult
}

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
