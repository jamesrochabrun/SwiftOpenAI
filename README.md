# SwiftOpenAI
<img width="1090" alt="repoOpenAI" src="https://github.com/jamesrochabrun/SwiftOpenAI/assets/5378604/51bc5736-a32f-4a9f-922e-209d950e28f7">

[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)
[![swift-version](https://img.shields.io/badge/swift-5.9-brightgreen.svg)](https://github.com/apple/swift)
[![swiftui-version](https://img.shields.io/badge/swiftui-brightgreen)](https://developer.apple.com/documentation/swiftui)
[![xcode-version](https://img.shields.io/badge/xcode-15%20-brightgreen)](https://developer.apple.com/xcode/)
[![swift-package-manager](https://img.shields.io/badge/package%20manager-compatible-brightgreen.svg?logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB3aWR0aD0iNjJweCIgaGVpZ2h0PSI0OXB4IiB2aWV3Qm94PSIwIDAgNjIgNDkiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+CiAgICA8IS0tIEdlbmVyYXRvcjogU2tldGNoIDYzLjEgKDkyNDUyKSAtIGh0dHBzOi8vc2tldGNoLmNvbSAtLT4KICAgIDx0aXRsZT5Hcm91cDwvdGl0bGU+CiAgICA8ZGVzYz5DcmVhdGVkIHdpdGggU2tldGNoLjwvZGVzYz4KICAgIDxnIGlkPSJQYWdlLTEiIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPgogICAgICAgIDxnIGlkPSJHcm91cCIgZmlsbC1ydWxlPSJub256ZXJvIj4KICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIGZpbGw9IiNEQkI1NTEiIHBvaW50cz0iNTEuMzEwMzQ0OCAwIDEwLjY4OTY1NTIgMCAwIDEzLjUxNzI0MTQgMCA0OSA2MiA0OSA2MiAxMy41MTcyNDE0Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDI1IDMxIDI1IDM1IDI1IDM3IDI1IDM3IDE0IDI1IDE0IDI1IDI1Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRUZDNzVFIiBwb2ludHM9IjEwLjY4OTY1NTIgMCAwIDE0IDYyIDE0IDUxLjMxMDM0NDggMCI+PC9wb2x5Z29uPgogICAgICAgICAgICA8cG9seWdvbiBpZD0iUmVjdGFuZ2xlIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDAgMzUgMCAzNyAxNCAyNSAxNCI+PC9wb2x5Z29uPgogICAgICAgIDwvZz4KICAgIDwvZz4KPC9zdmc+)](https://github.com/apple/swift-package-manager)

An open-source Swift package designed for effortless interaction with OpenAI's public API. 

## Table of Contents
- [Description](#description)
- [Getting an API Key](#getting-an-api-key)
- [Installation](#installation)
- [Usage](#usage)

## Description

`SwiftOpenAI` is an open-source Swift package that streamlines interactions with **all** OpenAI's API endpoints.

### OpenAI ENDPOINTS

- [Audio](#audio)
- [Chat](#chat)
- [Embeddings](#embeddings)
- [Fine-tuning](#fine-tuning)
- [Files](#files)
- [Images](#images)
- [Models](#models)
- [Moderations](#moderations)

## Getting an API Key

⚠️ **Important**

To interact with OpenAI services, you'll need an API key. Follow these steps to obtain one:

1. Visit [OpenAI](https://www.openai.com/).
2. Sign up for an [account](https://platform.openai.com/signup) or [log in](https://platform.openai.com/login) if you already have one.
3. Navigate to the [API key page](https://platform.openai.com/account/api-keys) and follow the instructions to generate a new API key.

For more information, consult OpenAI's [official documentation](https://platform.openai.com/docs/).

## Installation

### Swift Package Manager

1. Open your Swift project in Xcode.
2. Go to `File` ->  `Add Package Dependency`.
3. In the search bar, enter [this URL](https://github.com/jamesrochabrun/SwiftOpenAI).
4. Choose the version you'd like to install.
5. Click `Add Package`.

## Usage

To use SwiftOpenAI in your project, first import the package:

```swift
import SwiftOpenAI
```

Then, initialize the service using your OpenAI API key:

```swift
let apiKey = "your-openai-api-key-here"
let service = OpenAIServiceFactory.service(apiKey: apiKey)
```

You can optionally specify an organization name if needed.

```swift
let apiKey = "your-openai-api-key-here"
let oganizationID = "your_id"
let service = OpenAIServiceFactory.service(apiKey: apiKey, organizationID: oganizationID)
```

That's all you need to begin accessing the full range of OpenAI endpoints.

### Audio
### Chat
### Embeddings
### Fine-tuning
### Files
### Images
### Models
### Moderations


