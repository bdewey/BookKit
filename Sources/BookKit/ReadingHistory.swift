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

/// Keeps track of your reading history with a single book.
///
/// `ReadingHistory` is designed to handle a wide range of precise and imprecise reading histories, such as:
///
/// - "I've read this book before"
/// - "I've read this book multiple times before"
/// - "I read this book in 2018"
/// - "I'm reading this book now"
/// - "I started reading this book last Friday"
/// - "I read this book from June 28 through July 3, 2021"
public struct ReadingHistory: Codable, Hashable {
  public init(hasRead: Bool = false, multipleReadings: Bool = false, entries: [ReadingHistory.Entry]? = nil) {
    self.hasRead = hasRead
    self.multipleReadings = multipleReadings
    self.entries = entries
  }

  /// True if you have read this book
  public var hasRead: Bool = false

  /// True if you have read this book multiple times before.
  public var multipleReadings: Bool = false {
    didSet {
      if multipleReadings {
        hasRead = true
      }
    }
  }

  /// True if you are currently reading this book.
  public var isCurrentlyReading: Bool {
    guard let entries = entries else { return false }
    for entry in entries where entry.isCurrentlyReading {
      return true
    }
    return false
  }

  /// Record the start of reading a book.
  ///
  /// - parameter startDate: When you started reading the book. Can be nil if you don't remember / don't want to specify the start.
  public mutating func startReading(startDate: DateComponents? = nil) {
    guard !isCurrentlyReading else { return }
    let entry = Entry(start: startDate, finish: nil)
    if entries == nil {
      entries = [entry]
    } else {
      entries!.append(entry)
    }
    assert(isCurrentlyReading)
  }

  /// Record the finish of reading a book.
  ///
  /// While `finishDate` is non-nil to mark a book as "finished", you can provide as much or as little detail as you want. If all of the fields of `finishDate` are nil,
  /// for example, you are saying that you finished reading the book, but you're saying nothing about *when*. Or, you can just set the `year`, or you can set year / month / day,
  /// etc.
  ///
  /// - parameter finishDate: When you finished the book.
  public mutating func finishReading(finishDate: DateComponents) {
    if entries != nil {
      entries!.finishReading(finishDate: finishDate)
    } else {
      let entry = Entry(start: nil, finish: finishDate)
      entries = [entry]
    }
    assert(!isCurrentlyReading)
  }

  /// Individual reading records.
  public var entries: [Entry]?

  /// Represents a single reading "encounter" with a book.
  public struct Entry: Codable, Hashable {
    public var start: DateComponents?
    public var finish: DateComponents?

    /// True if this entry indicates that the person is currently reading
    public var isCurrentlyReading: Bool {
      finish == nil
    }
  }
}

private extension Array where Element == ReadingHistory.Entry {
  mutating func finishReading(finishDate: DateComponents) {
    for index in indices where self[index].isCurrentlyReading {
      self[index].finish = finishDate
      return
    }
    let entry = ReadingHistory.Entry(start: nil, finish: finishDate)
    append(entry)
  }
}
