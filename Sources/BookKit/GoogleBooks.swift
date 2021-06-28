//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.

import Foundation

/// Contains utility functions for working with the Google Books API.
///
/// For more information, see https://developers.google.com/books.
public enum GoogleBooks {
  /// A response for a Google Search request.
  public struct SearchResponse: Codable {
    public var totalItems: Int
    public var items: [Item]
  }

  /// An individual item in a Google Books search.
  public struct Item: Codable {
    public var id: String
    public var volumeInfo: VolumeInfo
  }

  /// Valid industry identifiers.
  public enum IndustryIdentifierType: String, Codable {
    case isbn10 = "ISBN_10"
    case isbn13 = "ISBN_13"
    case issn = "ISSN"
    case other = "OTHER"
  }

  /// An industry identifier for a book.
  public struct IndustryIdentifier: Codable {
    public var type: IndustryIdentifierType
    public var identifier: String
  }

  /// The book itself.
  public struct VolumeInfo: Codable {
    public var title: String?
    public var subtitle: String?
    public var authors: [String]?
    public var publishedDate: String?
    public var imageLinks: ImageLink?
    public var industryIdentifiers: [IndustryIdentifier]?
    public var pageCount: Int?
    public var publisher: String?
  }

  /// A book cover image.
  public struct ImageLink: Codable {
    public var smallThumbnail: String?
    public var thumbnail: String?
  }

  public enum GoogleBooksError: Error {
    case invalidURL
    case unknown
  }

  @available(iOS, deprecated: 15.0, message: "Use async version instead")
  public static func search(
    for searchTerm: String,
    apiKey: String,
    completion: @escaping (Result<SearchResponse, Error>) -> Void
  ) -> URLSessionDataTask? {
    var urlComponents = URLComponents(string: "https://www.googleapis.com/books/v1/volumes")!
    urlComponents.queryItems = [
      URLQueryItem(name: "q", value: searchTerm),
      URLQueryItem(name: "key", value: apiKey),
    ]
    guard let url = urlComponents.url else {
      completion(.failure(GoogleBooksError.invalidURL))
      return nil
    }
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
      if let error = error {
        DispatchQueue.main.async {
          completion(.failure(error))
        }
      } else if let data = data {
        do {
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategy = .iso8601
          let result = try decoder.decode(SearchResponse.self, from: data)
          DispatchQueue.main.async {
            completion(.success(result))
          }
        } catch {
          DispatchQueue.main.async {
            completion(.failure(error))
          }
        }
      } else {
        DispatchQueue.main.async {
          completion(.failure(GoogleBooksError.unknown))
        }
      }
    }
    task.resume()
    return task
  }

  @available(iOS 15.0, *)
  public static func search(for searchTerm: String, apiKey: String) async throws -> SearchResponse {
    var urlComponents = URLComponents(string: "https://www.googleapis.com/books/v1/volumes")!
    urlComponents.queryItems = [
      URLQueryItem(name: "q", value: searchTerm),
      URLQueryItem(name: "key", value: apiKey),
    ]
    guard let url = urlComponents.url else {
      throw GoogleBooksError.invalidURL
    }
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(SearchResponse.self, from: data)
  }
}

public extension Book {
  /// Construct a Book model from a Google Books search result.
  init?(_ item: GoogleBooks.Item) {
    guard let title = item.volumeInfo.title else {
      return nil
    }
    self.title = title
    self.authors = item.volumeInfo.authors ?? []
    self.numberOfPages = item.volumeInfo.pageCount
    self.publisher = item.volumeInfo.publisher
    if let datePrefix = item.volumeInfo.publishedDate?.prefix(4) {
      self.yearPublished = Int(datePrefix)
    }
    for identifier in item.volumeInfo.industryIdentifiers ?? [] {
      switch identifier.type {
      case .isbn10:
        self.isbn = identifier.identifier
      case .isbn13:
        self.isbn13 = identifier.identifier
      case .issn, .other:
        // ignore
        break
      }
    }
  }
}
