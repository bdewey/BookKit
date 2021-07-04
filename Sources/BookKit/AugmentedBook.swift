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

/// A struct that augments `Book` to include various personal information, like review & rating.
///
/// `AugmentedBook` is "JSON compatible" with the underlying `Book` type. If you encoded a `AugmentedBook`, you can decode it as a `Book` (and lose the review/rating).
/// Similarly, if you have an encoded `Book`, you can decode it as a `AugmentedBook` with a nil review/rating.
///
/// `AugmentedBook` dynamically forwards `Book` key paths to the underlying Book, so you can just reference `reviewedBook.title` instead of `reviewedBook.book.title`
@dynamicMemberLookup
public struct AugmentedBook: Codable, Hashable {
  public init(title: String, authors: [String], review: String? = nil, rating: Int? = nil, dateAdded: Date? = nil) {
    self.book = Book(title: title, authors: authors)
    self.review = review
    self.rating = rating
    self.dateAdded = dateAdded
  }

  public init(book: Book, review: String? = nil, rating: Int? = nil, dateAdded: Date? = nil) {
    self.book = book
    self.review = review
    self.rating = rating
    self.dateAdded = dateAdded
  }

  public init(_ book: Book) {
    self.book = book
  }

  /// The underlying review.
  public var book: Book

  /// A written review of this book.
  public var review: String?

  /// A rating for this book.
  public var rating: Int?

  /// When this date was added into a personal collection.
  public var dateAdded: Date?

  /// Your reading history with this book.
  public var readingHistory: ReadingHistory?

  private enum CodingKeys: CodingKey {
    case review
    case rating
    case dateAdded
    case readingHistory
  }

  public init(from decoder: Decoder) throws {
    self.book = try Book(from: decoder)
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.review = try container.decodeIfPresent(String.self, forKey: .review)
    self.rating = try container.decodeIfPresent(Int.self, forKey: .rating)
    self.dateAdded = try container.decodeIfPresent(Date.self, forKey: .dateAdded)
    self.readingHistory = try container.decodeIfPresent(ReadingHistory.self, forKey: .readingHistory)
  }

  public func encode(to encoder: Encoder) throws {
    try book.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(review, forKey: .review)
    try container.encode(rating, forKey: .rating)
    try container.encode(dateAdded, forKey: .dateAdded)
    try container.encode(readingHistory, forKey: .readingHistory)
  }

  public subscript<T>(dynamicMember keyPath: WritableKeyPath<Book, T>) -> T {
    get { book[keyPath: keyPath] }
    set { book[keyPath: keyPath] = newValue }
  }
}
