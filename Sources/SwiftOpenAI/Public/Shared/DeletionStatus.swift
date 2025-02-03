//
//  DeletionStatus.swift
//
//
//  Created by James Rochabrun on 4/27/24.
//

import Foundation

public struct DeletionStatus: Decodable {
   public let id: String
   public let object: String
   public let deleted: Bool
}
