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

// swiftlint:disable identifier_name

import Combine
import Foundation
import UniformTypeIdentifiers

/// Represents a book in the JSON format exported from LibraryThing.
public struct LibraryThingBook: Codable {
  public var title: String
  public var authors: [LibraryThingAuthor]
  public var date: Int?
  public var review: String?
  public var rating: Int?
  public var isbn: [String: String]?
  public var entrydate: DayComponents?
  public var genre: [String]?
  public var pages: Int?

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.title = try container.decode(String.self, forKey: .title)
    // LibraryThing encodes "no authors" as "an array with an empty array", not "an empty array"
    self.authors = (try? container.decode([LibraryThingAuthor].self, forKey: .authors)) ?? []
    self.date = Int(try container.decode(String.self, forKey: .date))
    self.review = try? container.decode(String.self, forKey: .review)
    self.rating = try? container.decode(Int.self, forKey: .rating)
    self.isbn = try? container.decode([String: String].self, forKey: .isbn)
    self.entrydate = try? container.decode(DayComponents.self, forKey: .entrydate)
    self.genre = try? container.decode([String].self, forKey: .genre)
    if let pageString = try? container.decode(String.self, forKey: .pages) {
      self.pages = Int(pageString.trimmingCharacters(in: .whitespaces))
    }
  }
}

public struct LibraryThingAuthor: Codable {
  public var lf: String?
  public var fl: String?
}

public extension Book {
  init(_ libraryThingBook: LibraryThingBook) {
    self.init(
      title: libraryThingBook.title,
      authors: libraryThingBook.authors.compactMap { $0.fl },
      yearPublished: libraryThingBook.date,
      originalYearPublished: nil,
      publisher: nil,
      isbn: libraryThingBook.isbn?["0"],
      isbn13: libraryThingBook.isbn?["2"],
      numberOfPages: libraryThingBook.pages,
      tags: nil
    )
  }
}

public extension AugmentedBook {
  init(_ libraryThingBook: LibraryThingBook) {
    self.book = Book(libraryThingBook)
    self.review = libraryThingBook.review
    self.rating = libraryThingBook.rating
    self.dateAdded = libraryThingBook.entrydate?.date
  }
}

extension String {
  func asGenreTag() -> String? {
    let coreGenre = lowercased()
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: #"[^\w\s]"#, with: "", options: .regularExpression)
      .replacingOccurrences(of: #"\s+"#, with: "-", options: .regularExpression)
    if coreGenre.isEmpty {
      return nil
    } else {
      return "#genre/" + coreGenre
    }
  }
}
