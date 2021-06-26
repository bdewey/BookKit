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

import BookKit
import XCTest

final class BookTests: XCTestCase {
  func testSerialization() throws {
    var reviewedBook = AugmentedBook(book: Book(title: "Testing", authors: ["Brian Dewey"]))
    reviewedBook.publisher = "Charlie Press"
    reviewedBook.rating = 3
    reviewedBook.review = "This is a test"
    reviewedBook.tags = ["#testing"]
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let encodedData = try encoder.encode(reviewedBook)
    let encodedText = String(data: encodedData, encoding: .utf8)!
    print(encodedText)

    // As expected, a ReviewedBook round-trips through its serialized form.
    let roundTrip = try JSONDecoder().decode(AugmentedBook.self, from: encodedData)
    XCTAssertEqual(roundTrip, reviewedBook)

    // Perhaps unexpectedly, you can decode just the Book from the same data.
    let roundTripBook = try JSONDecoder().decode(Book.self, from: encodedData)
    XCTAssertEqual(roundTripBook, reviewedBook.book)

    // If you encode just a Book, you can decode a ReviewedBook and review/rating will be nil.
    let bookData = try encoder.encode(reviewedBook.book)
    let decodedPartialReview = try JSONDecoder().decode(AugmentedBook.self, from: bookData)
    XCTAssertEqual(decodedPartialReview.book, reviewedBook.book)
    XCTAssertNil(decodedPartialReview.review)
    XCTAssertNil(decodedPartialReview.rating)
  }
}
