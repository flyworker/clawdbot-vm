# Configuring LLM Providers for Clawdbot

Clawdbot supports multiple LLM providers. This guide covers setting up different providers including MegaNova, Anthropic, and local models.

## Provider Options

| Provider | Best For | Pricing |
|----------|----------|---------|
| Anthropic | Complex tasks, coding, long context | Pay per token |
| MegaNova | Roleplay, chat, cost-effective | Pay per token (cheaper) |
| Local (Ollama) | Privacy, offline use | Free (your hardware) |

## MegaNova Setup

[MegaNova](https://www.meganova.ai/) provides an OpenAI-compatible API with models like DeepSeek, optimized for roleplay and character interactions.

### 1. Get API Key

1. Sign up at [meganova.ai](https://www.meganova.ai/)
2. Go to dashboard and generate an API key
3. Copy the key for configuration

### 2. Configure Clawdbot

Edit the config file:

```bash
nano ~/.config/clawdbot/config.json
```

Add MegaNova as a provider:

```json
{
  "models": {
    "providers": {
      "meganova": {
        "baseUrl": "https://inference.meganova.ai/v1",
        "apiKey": "YOUR_MEGANOVA_API_KEY",
        "api": "openai-completions",
        "models": [
          {
            "id": "deepseek-v3",
            "name": "DeepSeek V3",
            "contextWindow": 128000,
            "maxTokens": 128000
          },
          {
            "id": "llama-3.3-70b",
            "name": "Llama 3.3 70B",
            "contextWindow": 128000
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "meganova/deepseek-v3"
      }
    }
  }
}
```

### 3. Restart Clawdbot

```bash
clawdbot restart
```

## Anthropic Setup

[Anthropic](https://www.anthropic.com/) provides Claude models, recommended for complex reasoning and coding tasks.

### 1. Get API Key

1. Sign up at [console.anthropic.com](https://console.anthropic.com/)
2. Create an API key
3. Set usage limits to control spending

### 2. Configure Clawdbot

During `clawdbot onboard`, select Anthropic and enter your API key.

Or manually configure:

```json
{
  "models": {
    "providers": {
      "anthropic": {
        "apiKey": "sk-ant-your-key-here",
        "models": [
          {
            "id": "claude-sonnet-4-20250514",
            "name": "Claude Sonnet 4"
          },
          {
            "id": "claude-opus-4-5-20251101",
            "name": "Claude Opus 4.5"
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-sonnet-4-20250514"
      }
    }
  }
}
```

## Using Multiple Providers

You can configure multiple providers and switch between them:

```json
{
  "models": {
    "providers": {
      "anthropic": {
        "apiKey": "sk-ant-xxx"
      },
      "meganova": {
        "baseUrl": "https://inference.meganova.ai/v1",
        "apiKey": "your-meganova-key",
        "api": "openai-completions",
        "models": [
          {"id": "deepseek-v3", "name": "DeepSeek V3", "contextWindow": 128000}
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-sonnet-4-20250514",
        "fallback": "meganova/deepseek-v3"
      }
    }
  }
}
```

This uses Anthropic as primary and falls back to MegaNova if needed.

## Local Models (Ollama)

For complete privacy, run models locally with [Ollama](https://ollama.ai/).

### 1. Install Ollama (on host or in VM)

```bash
curl -fsSL https://ollama.ai/install.sh | sh
ollama pull llama3.3
```

### 2. Configure Clawdbot

```json
{
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "http://localhost:11434/v1",
        "apiKey": "ollama",
        "api": "openai-completions",
        "models": [
          {"id": "llama3.3", "name": "Llama 3.3", "contextWindow": 128000}
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/llama3.3"
      }
    }
  }
}
```

## Provider Comparison

| Feature | Anthropic | MegaNova | Local (Ollama) |
|---------|-----------|----------|----------------|
| Speed | Fast | Very Fast | Depends on hardware |
| Cost | $$$ | $ | Free |
| Privacy | Cloud | Cloud | Full privacy |
| Best models | Claude Opus 4.5 | DeepSeek V3 | Llama 3.3 |
| Context window | 200K | 128K | Varies |
| Coding | Excellent | Good | Good |
| Roleplay | Good | Excellent | Good |

## Troubleshooting

### Connection refused
```bash
# Check if the API is reachable
curl https://inference.meganova.ai/v1/models \
  -H "Authorization: Bearer YOUR_API_KEY"
```

### Invalid API key
- Verify the key is correct
- Check if the key has expired
- Ensure no extra whitespace

### Model not found
- Check the model ID matches exactly
- Verify the model is available on the provider

## Resources

- [MegaNova Docs](https://docs.meganova.ai)
- [Anthropic API Docs](https://docs.anthropic.com/)
- [Clawdbot Configuration](https://docs.clawd.bot/gateway/configuration)
- [Ollama Models](https://ollama.ai/library)
