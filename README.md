# BookKit
 
BookKit contains helper routines for dealing with common book-related services. It will help you:

1. Issue a query to Google Books and parse the result. (**Note:** You must have your own Google Books API key for this.)
2. Download cover images from OpenLibrary
3. Parse the JSON files from LibraryThing
4. Load a CSV file from Goodreads

## Code Overview

* `Book` is the core abstration of a "book" made available from any of the common book-tracking sites / services. The properties on `Book` are meant to be about *the book itself*, as opposed to *the relationship between the book and a person* (like when the book was added to a library, or how a reader rates the book).
* `AugmentedBook` extends `Book` to add the metadata that are personal to a particular person, like review/rating.
* `AugmentedBook+CSV.swift` contains utilities for loading `AugmentedBook` structs from CSV files saved from [Goodreads](https://www.goodreads.com).
* `LibraryThing` contains utilities for loading `AugmentedBook` structs from a JSON file saved from [LibraryThing](https://www.librarything.com).
* `GoogleBooks` contains utilities for searching for books from [Google Books](https://books.google.com/?hl=en).
* `OpenLibrary` contains utilities for downloading book covers from [Open Library](https://openlibrary.org).

## Changelog

### Version 0.4 - 2021-09-10

* Add an async `OpenLibrary.coverImage` method

### Version 0.3 - 2021-08-13

* Persist Google "categories" & LibraryThing "genres" as tags on the Book.

### Version 0.2.1 - 2021-07-07

Bugfix: Calling `ReadingHistory.finishReading()` now sets `hasRead` to `true`

### Version 0.2 - 2021-07-05

Added `ReadingHistory`

### Version 0.1 - 2021-06-27

Initial version.
