---
title: "Deep Chat: Building a Fully Customizable AI Chatbot Component - Complete Guide"
excerpt: "Learn how to integrate Deep Chat, a powerful AI chatbot component, into your website with just one line of code. Step-by-step tutorial covering installation, OpenAI integration, and advanced features like speech recognition and camera support."
seo_title: "Deep Chat AI Chatbot Tutorial: Complete Integration Guide - Thaki Cloud"
seo_description: "Comprehensive guide to Deep Chat - integrate AI chatbots with OpenAI, HuggingFace, and custom APIs. Includes React, Vue, Angular examples and speech-to-text features."
date: 2025-10-02
lang: en
permalink: /en/tutorials/deep-chat-ai-chatbot-complete-guide/
canonical_url: "https://thakicloud.github.io/en/tutorials/deep-chat-ai-chatbot-complete-guide/"
categories:
  - tutorials
tags:
  - deep-chat
  - ai-chatbot
  - openai
  - react
  - vue
  - angular
  - speech-to-text
  - web-components
author_profile: true
toc: true
toc_label: "Table of Contents"
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction

Deep Chat is a revolutionary web component that allows you to add a fully customizable AI chatbot to your website with just **one line of code**. Whether you're building a customer support system, an AI assistant, or a conversational interface, Deep Chat provides everything you need out of the box.

### What Makes Deep Chat Special?

- **Framework Agnostic**: Works with React, Vue, Angular, Svelte, and vanilla JavaScript
- **Direct API Connections**: Connect to OpenAI, HuggingFace, Cohere, and more
- **Rich Media Support**: Handle text, images, files, audio, and video
- **Speech Integration**: Built-in Speech-to-Text and Text-to-Speech
- **Fully Customizable**: Every aspect can be styled and configured
- **Browser-based LLM**: Run AI models entirely in the browser with Web LLM

## Part 1: Installation and Basic Setup

### Prerequisites

Before we begin, make sure you have:
- Node.js 14+ installed
- A package manager (npm, yarn, or pnpm)
- Basic knowledge of HTML and JavaScript

### Installation

For **vanilla JavaScript or TypeScript** projects:

```bash
npm install deep-chat
```

For **React** projects:

```bash
npm install deep-chat-react
```

### Basic Implementation

#### Vanilla JavaScript/HTML

Create a simple HTML file:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Deep Chat Demo</title>
    <script type="module">
        import 'deep-chat';
    </script>
</head>
<body>
    <deep-chat
        style="border-radius: 10px; width: 100%; height: 600px;"
        introMessage='{"text": "Welcome! How can I assist you today?"}'
    ></deep-chat>
</body>
</html>
```

#### React Implementation

```jsx
import { DeepChat } from 'deep-chat-react';

function App() {
    return (
        <div className="App">
            <DeepChat
                style={{borderRadius: '10px', width: '100%', height: '600px'}}
                introMessage={% raw %}{{text: "Welcome! How can I assist you today?"}}{% endraw %}
            />
        </div>
    );
}

export default App;
```

#### Vue 3 Implementation

```vue
<template>
    <deep-chat
        style="border-radius: 10px; width: 100%; height: 600px"
        :introMessage="introMessage"
    />
</template>

<script setup>
import 'deep-chat';

const introMessage = { text: "Welcome! How can I assist you today?" };
</script>
```

## Part 2: Connecting to OpenAI

One of Deep Chat's most powerful features is the ability to connect directly to AI services like OpenAI.

### Direct Connection (For Development Only)

**⚠️ Warning**: This method exposes your API key in the browser. Use only for local development/demos.

```html
<deep-chat
    directConnection='{
        "openAI": {
            "key": "your-api-key-here",
            "chat": {
                "model": "gpt-4",
                "max_tokens": 1000,
                "temperature": 0.7
            }
        }
    }'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### Production-Ready: Proxy Server

For production environments, create a backend proxy:

**Express.js Server Example:**

```javascript
// server.js
const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');

const app = express();
app.use(cors());
app.use(express.json());

app.post('/chat', async (req, res) => {
    try {
        const response = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
            },
            body: JSON.stringify({
                model: 'gpt-4',
                messages: req.body.messages,
                max_tokens: 1000,
                temperature: 0.7
            })
        });

        const data = await response.json();
        res.json({
            text: data.choices[0].message.content
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
```

**Frontend Configuration:**

```html
<deep-chat
    request='{"url": "http://localhost:3000/chat", "method": "POST"}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

## Part 3: Customizing the Chat Interface

### Adding Avatars and Names

```html
<deep-chat
    avatars='{
        "default": {
            "styles": {"avatar": {"width": "40px", "height": "40px"}}
        },
        "ai": {
            "src": "https://example.com/ai-avatar.png"
        },
        "user": {
            "src": "https://example.com/user-avatar.png"
        }
    }'
    names='{"ai": "AI Assistant", "user": "You"}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### Message Styling

```html
<deep-chat
    messageStyles='{
        "default": {
            "shared": {
                "bubble": {
                    "maxWidth": "80%",
                    "borderRadius": "12px",
                    "padding": "12px"
                }
            },
            "user": {
                "bubble": {
                    "backgroundColor": "#007AFF",
                    "color": "white"
                }
            },
            "ai": {
                "bubble": {
                    "backgroundColor": "#F0F0F0",
                    "color": "#000000"
                }
            }
        }
    }'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

## Part 4: Advanced Features

### 1. File Upload Support

Enable users to upload images and documents:

```html
<deep-chat
    textInput='{"files": {"button": {"position": "inside-left"}}}'
    request='{"url": "http://localhost:3000/upload", "method": "POST"}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### 2. Speech-to-Text Integration

Enable voice input:

```html
<deep-chat
    speechToText='{"webSpeech": true}'
    microphone='{"button": {"position": "inside-left"}}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### 3. Text-to-Speech for Responses

Have the AI read responses aloud:

```html
<deep-chat
    textToSpeech='{"webSpeech": true}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### 4. Camera Integration

Capture photos directly in the chat:

```html
<deep-chat
    camera='{"button": {"position": "inside-left"}}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### 5. Markdown Support

Enable rich text formatting:

```html
<deep-chat
    textToSpeech='{"displayMarkdown": true}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

## Part 5: Browser-Based LLM with Web Model

Run AI models entirely in the browser without any server:

**Step 1: Install the Web LLM package**

```bash
npm install deep-chat-web-llm
```

**Step 2: Configure Deep Chat**

```html
<script type="module">
    import 'deep-chat';
    import 'deep-chat-web-llm';
</script>

<deep-chat
    webModel='{"model": "Mistral-7B-Instruct-v0.2-q4f32_1"}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

**Benefits:**
- ✅ No API costs
- ✅ Complete privacy (data never leaves the browser)
- ✅ Works offline
- ✅ No server required

## Part 6: Handling Messages Programmatically

### React Example with Custom Logic

```jsx
import { DeepChat } from 'deep-chat-react';
import { useState } from 'react';

function App() {
    const [chatHistory, setChatHistory] = useState([]);

    const handleNewMessage = (message) => {
        console.log('New message:', message);
        setChatHistory(prev => [...prev, message]);
    };

    const customHandler = async (body, signals) => {
        try {
            // Custom API call
            const response = await fetch('https://your-api.com/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(body),
                signal: signals.controller.signal
            });

            const data = await response.json();
            
            // Return response in Deep Chat format
            return { text: data.message };
        } catch (error) {
            return { error: error.message };
        }
    };

    return (
        <DeepChat
            handler={customHandler}
            onMessage={handleNewMessage}
            style={% raw %}{{borderRadius: '10px', width: '100%', height: '600px'}}{% endraw %}
        />
    );
}
```

### Streaming Responses

For real-time streaming responses (like ChatGPT):

```javascript
const streamHandler = async (body, signals) => {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${API_KEY}`
        },
        body: JSON.stringify({
            ...body,
            stream: true
        }),
        signal: signals.controller.signal
    });

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let fullText = '';

    while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value);
        const lines = chunk.split('\n').filter(line => line.trim() !== '');

        for (const line of lines) {
            if (line.startsWith('data: ')) {
                const data = line.slice(6);
                if (data === '[DONE]') continue;

                try {
                    const parsed = JSON.parse(data);
                    const content = parsed.choices[0]?.delta?.content || '';
                    fullText += content;
                    signals.onResponse({ text: fullText });
                } catch (e) {
                    console.error('Parse error:', e);
                }
            }
        }
    }
};
```

## Part 7: Testing Your Implementation

### Create a Test Script

Save this as `test-deep-chat.sh`:

```bash
#!/bin/bash

echo "🚀 Deep Chat Test Script"
echo "========================"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

echo "✅ Node.js version: $(node --version)"

# Create test directory
TEST_DIR="deep-chat-test"
echo "📁 Creating test directory: $TEST_DIR"
mkdir -p $TEST_DIR
cd $TEST_DIR

# Initialize project
echo "📦 Initializing npm project..."
npm init -y

# Install dependencies
echo "📥 Installing deep-chat..."
npm install deep-chat

# Create test HTML file
echo "📝 Creating test HTML file..."
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Deep Chat Test</title>
    <script type="module">
        import 'deep-chat';
    </script>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
        }
        h1 {
            text-align: center;
            color: #007AFF;
        }
    </style>
</head>
<body>
    <h1>Deep Chat Test</h1>
    <deep-chat
        style="border-radius: 10px; width: 100%; height: 600px; border: 2px solid #007AFF;"
        introMessage='{"text": "Hello! I am your AI assistant. Try sending a message!"}'
        messageStyles='{
            "default": {
                "user": {
                    "bubble": {
                        "backgroundColor": "#007AFF",
                        "color": "white"
                    }
                }
            }
        }'
    ></deep-chat>
</body>
</html>
EOF

echo "✅ Test file created successfully!"
echo ""
echo "🌐 To test:"
echo "   1. Run: npx serve"
echo "   2. Open: http://localhost:3000"
echo ""
echo "📂 Test directory: $(pwd)"
```

### Run the Test

```bash
chmod +x test-deep-chat.sh
./test-deep-chat.sh
```

## Part 8: Best Practices and Tips

### 1. Security Best Practices

- **Never expose API keys in frontend code**
- Always use a backend proxy for production
- Implement rate limiting on your server
- Validate and sanitize all user inputs

### 2. Performance Optimization

```javascript
// Lazy load Deep Chat for better initial page load
const loadDeepChat = async () => {
    await import('deep-chat');
    // Initialize chat after loading
};

// Load when user scrolls to chat section
const observer = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting) {
        loadDeepChat();
        observer.disconnect();
    }
});

observer.observe(document.querySelector('#chat-container'));
```

### 3. Error Handling

```javascript
const chatElement = document.querySelector('deep-chat');

chatElement.addEventListener('error', (event) => {
    console.error('Chat error:', event.detail);
    // Show user-friendly error message
    chatElement.appendChild({
        role: 'ai',
        text: 'Sorry, I encountered an error. Please try again.'
    });
});
```

### 4. Accessibility

```html
<deep-chat
    aria-label="AI Chat Assistant"
    aria-describedby="chat-description"
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
<p id="chat-description" class="sr-only">
    An interactive chat interface to communicate with an AI assistant
</p>
```

## Complete Example: Full-Featured Chat Application

Here's a complete React application combining multiple features:

```jsx
import { DeepChat } from 'deep-chat-react';
import { useState } from 'react';

function FullFeaturedChat() {
    const [isLoading, setIsLoading] = useState(false);
    const [messageCount, setMessageCount] = useState(0);

    const customHandler = async (body, signals) => {
        setIsLoading(true);
        
        try {
            const response = await fetch('/api/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(body),
                signal: signals.controller.signal
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const data = await response.json();
            setMessageCount(prev => prev + 1);
            
            return { text: data.message };
        } catch (error) {
            console.error('Chat error:', error);
            return { 
                error: 'Sorry, I encountered an error. Please try again.' 
            };
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div style={% raw %}{{ 
            maxWidth: '1200px', 
            margin: '0 auto', 
            padding: '20px' 
        }}{% endraw %}>
            <div style={% raw %}{{ 
                marginBottom: '20px', 
                display: 'flex', 
                justifyContent: 'space-between' 
            }}{% endraw %}>
                <h1>AI Chat Assistant</h1>
                <div>
                    Messages: {messageCount}
                    {isLoading && ' (Loading...)'}
                </div>
            </div>

            <DeepChat
                handler={customHandler}
                introMessage={% raw %}{{
                    text: "👋 Welcome! I'm your AI assistant. I can help you with:\n\n" +
                          "• Answering questions\n" +
                          "• Analyzing images (upload a file)\n" +
                          "• Voice conversations (use the microphone)\n\n" +
                          "How can I assist you today?"
                }}{% endraw %}
                textInput={% raw %}{{
                    files: { button: { position: "inside-left" } },
                    placeholder: { text: "Type your message..." }
                }}{% endraw %}
                microphone={% raw %}{{ button: { position: "inside-left" } }}{% endraw %}
                speechToText={% raw %}{{ webSpeech: true }}{% endraw %}
                textToSpeech={% raw %}{{ webSpeech: true }}{% endraw %}
                camera={% raw %}{{ button: { position: "inside-left" } }}{% endraw %}
                avatars={% raw %}{{
                    ai: { 
                        src: "https://api.dicebear.com/7.x/bottts/svg?seed=ai" 
                    },
                    user: { 
                        src: "https://api.dicebear.com/7.x/personas/svg?seed=user" 
                    }
                }}{% endraw %}
                names={% raw %}{{ ai: "AI Assistant", user: "You" }}{% endraw %}
                messageStyles={% raw %}{{
                    default: {
                        shared: {
                            bubble: {
                                maxWidth: "80%",
                                borderRadius: "12px",
                                padding: "12px 16px"
                            }
                        },
                        user: {
                            bubble: {
                                backgroundColor: "#007AFF",
                                color: "white"
                            }
                        },
                        ai: {
                            bubble: {
                                backgroundColor: "#F0F0F0",
                                color: "#000000"
                            }
                        }
                    }
                }}{% endraw %}
                style={% raw %}{{
                    borderRadius: '16px',
                    border: '2px solid #E5E5EA',
                    width: '100%',
                    height: '700px',
                    boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)'
                }}{% endraw %}
            />
        </div>
    );
}

export default FullFeaturedChat;
```

## Conclusion

Deep Chat is a powerful and flexible solution for adding AI chat functionality to your web applications. With its extensive feature set, framework support, and customization options, you can create anything from simple chatbots to sophisticated AI assistants.

### Key Takeaways

1. **Easy Integration**: Add a chatbot with just one line of code
2. **Framework Flexibility**: Works with React, Vue, Angular, and more
3. **AI Service Integration**: Direct connection to OpenAI, HuggingFace, Cohere
4. **Rich Features**: Speech, camera, file uploads, and more
5. **Fully Customizable**: Style every aspect to match your brand
6. **Production Ready**: Proper security practices with backend proxies

### Next Steps

- Explore the official documentation at [deepchat.dev](https://deepchat.dev)
- Check out the GitHub repository for more examples
- Join the community and contribute
- Build your own custom integrations

### Resources

- 📚 [Official Documentation](https://deepchat.dev)
- 💻 [GitHub Repository](https://github.com/OvidijusParsiunas/deep-chat)
- 🎮 [Interactive Playground](https://deepchat.dev/playground)
- 📺 [Video Tutorials](https://www.youtube.com/@DeepChat)

Happy coding! 🚀

