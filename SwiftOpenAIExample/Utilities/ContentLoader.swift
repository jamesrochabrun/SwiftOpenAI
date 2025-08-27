//
//  ContentLoader.swift
//  SwiftOpenAIExample
//
//  Created by James Rochabrun on 10/19/23.
//

import Foundation

struct ContentLoader {
  enum Error: Swift.Error {
    case fileNotFound(name: String)
    case fileDecodingFailed(name: String, Swift.Error)
  }

  func urlFromAsset(fromFileNamed name: String, ext: String) -> URL? {
    guard
      let url = Bundle.main.url(
        forResource: name,
        withExtension: ext)
    else {
      return nil
    }
    return url
  }

  func loadBundledContent(fromFileNamed name: String, ext: String) throws -> Data {
    guard let url = urlFromAsset(fromFileNamed: name, ext: ext) else {
      throw Error.fileNotFound(name: name)
    }

    do {
      return try Data(contentsOf: url)
    } catch {
      throw Error.fileDecodingFailed(name: name, error)
    }
  }
}
