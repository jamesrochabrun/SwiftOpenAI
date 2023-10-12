//
//  MultipartFormDataParameters.swift
//
//
//  Created by James Rochabrun on 10/11/23.
//

import Foundation

protocol MultipartFormDataParameters {
   
   func encode(boundary: String) -> Data
}
