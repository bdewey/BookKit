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

/// Core model for a *book*.
///
/// The properties on `Book` are meant to be about *the book itself*, as opposed to *the relationship between the book and a person* (like when the book was added to a library, or how a reader rates the book).
public struct Book: Hashable, Codable, Sendable {
  public init(title: String, authors: [String], yearPublished: Int? = nil, originalYearPublished: Int? = nil, publisher: String? = nil, isbn: String? = nil, isbn13: String? = nil, numberOfPages: Int? = nil, tags: [String]? = nil) {
    self.title = title
    self.authors = authors
    self.yearPublished = yearPublished
    self.originalYearPublished = originalYearPublished
    self.publisher = publisher
    self.isbn = isbn
    self.isbn13 = isbn13
    self.numberOfPages = numberOfPages
    self.tags = tags
  }

  /// The book title
  public var title: String

  /// The book authors, in "First Last" format
  public var authors: [String]

  /// When this specific volume was published.
  public var yearPublished: Int?

  /// In the case of a work with multiple editions, this is the year the book was originally published.
  public var originalYearPublished: Int?

  /// The book publisher.
  public var publisher: String?

  /// 10-digit ISBN
  public var isbn: String?

  /// 13-digit ISBN
  public var isbn13: String?

  /// Number of pages in the book
  public var numberOfPages: Int?

  /// An arbitrary collection of tags for this book.
  public var tags: [String]?
}
