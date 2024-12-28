//
//  RemoteImageFeatcher.swift
//  LHAsyncImage
//
//  Created by Luiz Diniz Hammerli on 23/12/24.
//

import Foundation

actor RemoteImageFeatcher: ImageFeatchable {
    private let urlSession: URLSession
    private(set) var tasks = [URL: Task<Data, Error>]()

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func fetch(url: URL) async throws -> Data {
        if let currentTask = tasks[url] { return try await currentTask.value }

        let newTask = Task {
            do {
                let (data, response) = try await urlSession.data(from: url)

                tasks.removeValue(forKey: url)

                guard let httpResponse = response as? HTTPURLResponse,
                      (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) else {
                    throw ImageError.invalidResponse
                }

                return data
            } catch {
                tasks.removeValue(forKey: url)
                throw(error)
            }
        }

        tasks[url] = newTask
        return try await newTask.value
    }
}
