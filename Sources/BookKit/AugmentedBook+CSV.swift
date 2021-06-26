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

import CodableCSV
import Foundation
import Logging

public extension AugmentedBook {
  enum GoodreadsHeader: String, CaseIterable {
    case title
    case author
    case isbn
    case isbn13
    case rating = "My Rating"
    case publisher
    case numberOfPages = "Number of Pages"
    case yearPublished = "Year Published"
    case dateAdded = "Date Added"
    case review = "My review"
  }

  /// Loads books from a CSV exported from Goodreads.
  /// - parameter url: A URL to the exported Goodreads file.
  /// - returns: An array of `ReviewedBook` structs from the file.
  static func loadGoodreadsCSV(url: URL) throws -> [AugmentedBook] {
    let result = try CSVReader.decode(input: url) {
      $0.headerStrategy = .firstLine
    }
    Logger.csv.info("Read \(result.count) rows: \(result.headers)")
    var actualHeaderNames = [GoodreadsHeader: String]()
    for expectedHeader in GoodreadsHeader.allCases {
      for actualHeader in result.headers {
        if actualHeader.trimmingCharacters(in: .whitespaces).compare(expectedHeader.rawValue, options: [.caseInsensitive]) == .orderedSame {
          actualHeaderNames[expectedHeader] = actualHeader
        }
      }
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY/MM/dd"
    guard let titleHeader = actualHeaderNames[.title], let authorHeader = actualHeaderNames[.author] else {
      throw CSVError.missingColumn
    }
    return result.records.map { record -> AugmentedBook in
      let title = record[titleHeader] ?? ""
      let author = record[authorHeader] ?? ""
      var book = AugmentedBook(title: title, authors: [author])
      book.isbn = record.value(actualHeaderNames, header: .isbn)
      book.isbn13 = record.value(actualHeaderNames, header: .isbn13)
      book.rating = record.value(actualHeaderNames, header: .rating).flatMap(Int.init)
      book.publisher = record.value(actualHeaderNames, header: .publisher)
      book.numberOfPages = record.value(actualHeaderNames, header: .numberOfPages).flatMap(Int.init)
      book.yearPublished = record.value(actualHeaderNames, header: .yearPublished).flatMap(Int.init)
      book.review = record.value(actualHeaderNames, header: .review)
      book.dateAdded = record.value(actualHeaderNames, header: .dateAdded).flatMap(dateFormatter.date) ?? Date()
      return book
    }
  }
}

public enum CSVError: String, Error {
  case missingColumn = "The CSV file is missing a required column"
}

// MARK: - Private

private extension Logger {
  static let csv: Logger = {
    var logger = Logger(label: "org.brians-brain.BookKit.CSV")
    logger.logLevel = .info
    return logger
  }()
}

private extension CSVReader.Record {
  func value(_ actualHeaderNames: [AugmentedBook.GoodreadsHeader: String], header: AugmentedBook.GoodreadsHeader) -> String? {
    guard let actualHeader = actualHeaderNames[header], let value = self[actualHeader] else { return nil }
    // Look for things encoded as `="something"` and return just the `something`
    if value.hasPrefix("=\""), value.hasSuffix("\"") {
      return String(value.dropFirst(2).dropLast())
    } else {
      return value
    }
  }
}
