//
//  Delta.swift
//  
//
//  Created by James Rochabrun on 3/22/24.
//

import Foundation

/// Protocol for Assistant Stream Delta.
/// Defines a set of requirements for objects that can be included in an assistant event stream, such as `RunStepDeltaObject` or `MessageDeltaObject`.
public protocol Delta: Decodable {
   associatedtype T
   var id: String { get }
   var object: String { get }
   var delta: T { get }
}
