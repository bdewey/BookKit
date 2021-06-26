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

import Combine
import UIKit
import UniformTypeIdentifiers

public enum OpenLibrary {
  // TODO: Write an async version of this.
  /// A Combine publisher that downloads a medium-sized cover image for a book from OpenLibrary.
  public static func coverImagePublisher(isbn: String) -> AnyPublisher<TypedData, Error> {
    guard let url = URL(string: "https://covers.openlibrary.org/b/isbn/\(isbn)-M.jpg") else {
      return Fail<TypedData, Error>(error: URLError(.badURL)).eraseToAnyPublisher()
    }
    return URLSession.shared.dataTaskPublisher(for: url)
      .tryMap { data, response in
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
          throw URLError(.badServerResponse)
        }
        if let mimeType = httpResponse.mimeType, let type = UTType(mimeType: mimeType) {
          return TypedData(data: data, type: type)
        }
        if let image = UIImage(data: data), let jpegData = image.jpegData(compressionQuality: 0.8) {
          return TypedData(data: jpegData, type: .jpeg)
        }
        throw URLError(.cannotDecodeRawData)
      }
      .eraseToAnyPublisher()
  }
}
