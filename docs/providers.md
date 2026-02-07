# Configuring LLM Providers for OpenClaw

OpenClaw supports multiple LLM providers. This guide covers setting up different providers including MegaNova, Anthropic, and local models.

## Provider Options

| Provider | Best For | Pricing |
|----------|----------|---------|
| Anthropic | Complex tasks, coding, long context | Pay per token |
| MegaNova | Roleplay, chat, cost-effective | Pay per token (cheaper) |
| Local (Ollama) | Privacy, offline use | Free (your hardware) |

## MegaNova Setup

[MegaNova](https://www.meganova.ai/) provides an OpenAI-compatible API (vLLM-based) with models like DeepSeek and Kimi.

### 1. Get API Key

1. Sign up at [meganova.ai](https://www.meganova.ai/)
2. Go to dashboard and generate an API key
3. Copy the key for configuration

### 2. Check Available Models

```bash
curl https://inference.meganova.ai/v1/models \
  -H "Authorization: Bearer YOUR_API_KEY"
```

Use the exact model ID from the response (e.g. `deepseek-ai/DeepSeek-V3-0324`, `moonshotai/Kimi-K2-Thinking`).

### 3. Configure OpenClaw

Edit the config file:

```bash
nano ~/.openclaw/openclaw.json
```

Add the `models` block to your config:

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
            "id": "deepseek-ai/DeepSeek-V3-0324",
            "name": "DeepSeek V3",
            "contextWindow": 128000,
            "maxTokens": 128000
          },
          {
            "id": "moonshotai/Kimi-K2-Thinking",
            "name": "Kimi K2 Thinking",
            "contextWindow": 128000
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "meganova/deepseek-ai/DeepSeek-V3-0324"
      }
    }
  }
}
```

### 4. Restart OpenClaw

```bash
openclaw gateway restart
```

### Known Issues

MegaNova uses vLLM which is strict about unknown request fields. If you get HTTP 400 errors about unsupported fields (e.g. `store`), use the included proxy script which strips unsupported parameters:

```bash
pip3 install flask requests
MEGANOVA_API_KEY=your-key python3 scripts/meganova_proxy.py
```

Then set `baseUrl` to `http://127.0.0.1:4000/v1` in your config.

## Anthropic Setup

[Anthropic](https://www.anthropic.com/) provides Claude models, recommended for complex reasoning and coding tasks.

### 1. Get API Key

1. Sign up at [console.anthropic.com](https://console.anthropic.com/)
2. Create an API key
3. Set usage limits to control spending

### 2. Configure OpenClaw

During `openclaw onboard`, select Anthropic and enter your API key.

Or manually edit `~/.openclaw/openclaw.json`:

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
          {"id": "deepseek-ai/DeepSeek-V3-0324", "name": "DeepSeek V3", "contextWindow": 128000}
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-sonnet-4-20250514",
        "fallback": "meganova/deepseek-ai/DeepSeek-V3-0324"
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

### 2. Configure OpenClaw

Edit `~/.openclaw/openclaw.json`:

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
| Best models | Claude Opus 4.5 | DeepSeek V3, Kimi K2 | Llama 3.3 |
| Context window | 200K | 128K | Varies |
| Coding | Excellent | Good | Good |
| Roleplay | Good | Excellent | Good |
| Backend | Proprietary | vLLM | Ollama |

## Troubleshooting

### HTTP 400 from MegaNova
MegaNova uses vLLM which rejects unknown fields. Use the proxy script (`scripts/meganova_proxy.py`) to strip unsupported parameters.

### Model not found (404)
Use the full model ID from `curl https://inference.meganova.ai/v1/models`. For example, use `deepseek-ai/DeepSeek-V3-0324` not `deepseek-v3`.

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

### Config file location
The config file is at `~/.openclaw/openclaw.json` (not `config.json`).

## Resources

- [MegaNova](https://www.meganova.ai/)
- [Anthropic API Docs](https://docs.anthropic.com/)
- [OpenClaw Docs](https://docs.openclaw.ai/)
- [Ollama Models](https://ollama.ai/library)
