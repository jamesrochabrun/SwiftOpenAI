//
//  AgentSessionParameters.swift
//  SwiftOpenAI
//
//  Created by James Rochabrun on 10/1/26.
//

import Foundation

// MARK: - AgentSessionParameters

/// [Create an agent session.](https://developers.openai.com/api/docs/guides/agents-api/quickstart)
///
/// The Agents API gives access to the managed Codex harness: OpenAI handles sessions,
/// orchestration, context compaction and recovery. The API is in public beta and requires
/// the `OpenAI-Beta: agents=v1` header, which the service adds automatically.
public struct AgentSessionParameters: Encodable {

  public init(
    agent: Agent,
    environment: Environment? = nil,
    input: String? = nil,
    stream: Bool? = nil)
  {
    self.agent = agent
    self.environment = environment
    self.input = input
    self.stream = stream
  }

  // MARK: - Agent

  /// The model, instructions, tools, and MCP servers available to the agent.
  public struct Agent: Encodable {

    public init(
      model: Model,
      instructions: String? = nil,
      tools: [Tool]? = nil)
    {
      self.model = model.value
      self.instructions = instructions
      self.tools = tools
    }

    /// The model that powers the agent, e.g. `.gpt6Astra`.
    public var model: String
    /// Custom instructions for the agent.
    public var instructions: String?
    /// Tools available to the agent.
    public var tools: [Tool]?
  }

  // MARK: - Tool

  /// A tool the agent can use during the session.
  public enum Tool: Encodable {
    /// Lets the agent operate software through its UI.
    /// Screenshots are optional but recommended for displaying progress.
    case computerUse(includeScreenshots: Bool? = nil)
    /// Lets the agent search the web.
    case webSearch
    /// Escape hatch for tool declarations not yet modeled by this SDK, e.g. MCP servers.
    /// The dictionary is encoded verbatim as the tool object.
    case custom([String: OpenAIJSONValue])

    public func encode(to encoder: Encoder) throws {
      switch self {
      case .computerUse(let includeScreenshots):
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("computer_use", forKey: .type)
        try container.encodeIfPresent(includeScreenshots, forKey: .includeScreenshots)

      case .webSearch:
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("web_search", forKey: .type)

      case .custom(let object):
        var container = encoder.singleValueContainer()
        try container.encode(object)
      }
    }

    private enum CodingKeys: String, CodingKey {
      case type
      case includeScreenshots = "include_screenshots"
    }
  }

  // MARK: - Environment

  /// An optional sandbox or computer where the agent accesses files, loads skills, and runs commands.
  public struct Environment: Encodable {

    public init(
      type: EnvironmentType,
      desktop: Desktop? = nil)
    {
      self.type = type.rawValue
      self.desktop = desktop
    }

    /// The environment type: `openai_hosted` for an OpenAI-hosted sandbox, or `none`
    /// for question-answering or external tool calls that need no sandbox.
    public var type: String
    /// Desktop configuration, required for browser access with the computer use tool.
    public var desktop: Desktop?
  }

  /// Known environment types.
  public enum EnvironmentType: String {
    case openAIHosted = "openai_hosted"
    case none
  }

  /// Desktop configuration for computer use.
  public struct Desktop: Encodable {
    public init(enabled: Bool) {
      self.enabled = enabled
    }

    public var enabled: Bool
  }

  /// The agent configuration.
  public var agent: Agent
  /// The environment the agent runs in.
  public var environment: Environment?
  /// The initial prompt or task.
  public var input: String?
  /// If set to true, session events are streamed to the client as server-sent events.
  public var stream: Bool?
}
