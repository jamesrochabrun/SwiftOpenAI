//
//  MessageObject.swift
//
//
//  Created by James Rochabrun on 11/15/23.
//

import Foundation

/// BETA.
/// Represents a [message](https://platform.openai.com/docs/api-reference/messages) within a [thread](https://platform.openai.com/docs/api-reference/threads).
public struct MessageObject: Decodable {
   
   /// The identifier, which can be referenced in API endpoints.
   public let id: String
   /// The object type, which is always thread.message.
   public let object: String
   /// The Unix timestamp (in seconds) for when the message was created.
   public let createdAt: Int
   /// The [thread](https://platform.openai.com/docs/api-reference/threads) ID that this message belongs to.
   public let threadID: String
   /// The entity that produced the message. One of user or assistant.
   public let role: String
   /// The content of the message in array of text and/or images.
   public let content: [Content]
   /// If applicable, the ID of the [assistant](https://platform.openai.com/docs/api-reference/assistants) that authored this message.
   let assistantID: String?
   /// If applicable, the ID of the [run](https://platform.openai.com/docs/api-reference/runs) associated with the authoring of this message.
   let runID: String?
   /// A list of [file](https://platform.openai.com/docs/api-reference/files) IDs that the assistant should use. Useful for tools like retrieval and code_interpreter that can access files. A maximum of 10 files can be attached to a message.
   let fileIDS: [String]
   /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
   public let metadata: [String: String]
   
   enum Role: String {
      case user
      case assistant
   }
   
   // MARK: Content
   public enum Content: Decodable {
      
      case imageFile(ImageFile)
      case text(Text)
      
      // MARK: Image File

      /// References an image [File](https://platform.openai.com/docs/api-reference/files) in the content of a message.
      public struct ImageFile: Decodable {
         /// Always image_file.
         let type: String
         
         public struct ImageFile: Decodable {
            
            /// The [File](https://platform.openai.com/docs/api-reference/files) ID of the image in the message content.
            public let fileID: String
            
            enum CodingKeys: String, CodingKey {
               case fileID = "file_id"
            }
         }
      }
      
      // MARK: Text

      /// The text content that is part of a message.
      public struct Text: Decodable {
         
         /// Always text.
         public let type: String
         
         public struct Text: Decodable {
            /// The data that makes up the text.
            public let value: String
            
            public let annotations: [Annotation]
            
            public enum Annotation: Decodable {
               
               case fileCitation(FileCitation)
               case filePath(FilePath)
               
               /// A citation within the message that points to a specific quote from a specific File associated with the assistant or the message. Generated when the assistant uses the "retrieval" tool to search files.
               public struct FileCitation: Decodable {
                  
                  /// Always file_citation.
                  public let type: String
                  /// The text in the message content that needs to be replaced.
                  public let text: String
                  public let fileCitation: FileCitation
                  public  let startIndex: Int
                  public let endIndex: Int
                  
                  public struct FileCitation: Decodable {
                     
                     /// The ID of the specific File the citation is from.
                     public let fileID: String
                     /// The specific quote in the file.
                     public let quote: String
                     
                     enum CodingKeys: String, CodingKey {
                        case fileID = "file_id"
                        case quote
                     }
                  }
                  
                  enum CodingKeys: String, CodingKey {
                     case type
                     case text
                     case fileCitation = "file_citation"
                     case startIndex = "start_index"
                     case endIndex = "end_index"
                  }
               }
               
               /// A URL for the file that's generated when the assistant used the code_interpreter tool to generate a file.
               public struct FilePath: Decodable {
                  
                  /// Always file_path
                  public let type: String
                  /// The text in the message content that needs to be replaced.
                  public let text: String
                  public let filePath: FilePath
                  public let startIndex: Int
                  public let endIndex: Int
                  
                  public struct FilePath: Decodable {
                     /// The ID of the file that was generated.
                     public let fileID: String
                     
                     enum CodingKeys: String, CodingKey {
                        case fileID = "file_id"
                     }
                  }
                  
                  enum CodingKeys: String, CodingKey {
                     case type
                     case text
                     case filePath = "file_path"
                     case startIndex = "start_index"
                     case endIndex = "end_index"
                  }
               }
               
               private enum CodingKeys: String, CodingKey {
                  case type
                  case text
                  case fileCitation = "file_citation"
                  case filePath = "file_path"
                  case startIndex = "start_index"
                  case endIndex = "end_index"
               }
               
               private enum AnnotationTypeKey: CodingKey {
                  case type
               }
               
               public init(from decoder: Decoder) throws {
                  let container = try decoder.container(keyedBy: AnnotationTypeKey.self)
                  let type = try container.decode(String.self, forKey: .type)
                  switch type {
                  case "file_citation":
                     let fileCitationContainer = try decoder.container(keyedBy: CodingKeys.self)
                     let fileCitation = try fileCitationContainer.decode(FileCitation.self, forKey: .fileCitation)
                     self = .fileCitation(fileCitation)
                  case "file_path":
                     let filePathContainer = try decoder.container(keyedBy: CodingKeys.self)
                     let filePath = try filePathContainer.decode(FilePath.self, forKey: .filePath)
                     self = .filePath(filePath)
                  default:
                     throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type for annotation")
                  }
               }
            }
         }
      }
      
      private enum CodingKeys: String, CodingKey {
         case type
         case imageFile = "image_file"
         case text
      }
      
      private enum ContentTypeKey: CodingKey {
         case type
      }
      
      public init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: ContentTypeKey.self)
         let type = try container.decode(String.self, forKey: .type)
         
         switch type {
         case "image_file":
            let imageFileContainer = try decoder.container(keyedBy: CodingKeys.self)
            let imageFile = try imageFileContainer.decode(ImageFile.self, forKey: .imageFile)
            self = .imageFile(imageFile)
         case "text":
            let textContainer = try decoder.container(keyedBy: CodingKeys.self)
            let text = try textContainer.decode(Text.self, forKey: .text)
            self = .text(text)
         default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type for content")
         }
      }
   }

   
   enum CodingKeys: String, CodingKey {
      case id
      case object
      case createdAt = "created_at"
      case threadID = "thread_id"
      case role
      case content
      case assistantID = "assistant_id"
      case runID = "run_id"
      case fileIDS = "file_ids"
      case metadata
   }
}
