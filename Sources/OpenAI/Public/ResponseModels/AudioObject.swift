//
//  AudioObject.swift
//
//
//  Created by James Rochabrun on 10/10/23.
//

import Foundation

/// The [audio](https://platform.openai.com/docs/api-reference/audio) response.
public struct AudioObject: Decodable {
   
   /// The transcribed text if the request uses the `transcriptions` API, or the translated text if the request uses the `translations` endpoint.
   let text: String
}
