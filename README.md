# SwiftOpenAI

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


