#!/usr/bin/env python3
"""
Simple proxy for MegaNova API that strips unsupported parameters.
This allows clawdbot to work with MegaNova by only forwarding
the parameters that MegaNova accepts.
"""

from flask import Flask, request, jsonify
import requests
import json
import os

app = Flask(__name__)

MEGANOVA_URL = "https://api.meganova.ai/v1/chat/completions"
API_KEY = os.environ.get("MEGANOVA_API_KEY")
if not API_KEY:
    raise RuntimeError("MEGANOVA_API_KEY environment variable is required")

@app.route('/v1/chat/completions', methods=['POST'])
def chat_completions():
    data = request.json

    print("=== INCOMING REQUEST ===")
    print(f"Stream requested: {data.get('stream', False)}")
    print(json.dumps(data, indent=2, default=str)[:1000])

    # Simplify messages and convert format
    messages = []
    for msg in data.get("messages", []):
        role = msg.get("role", "user")
        content = msg.get("content", "")

        # Convert array format to string
        if isinstance(content, list):
            # Extract text from content array
            text_parts = []
            for part in content:
                if isinstance(part, dict) and part.get("type") == "text":
                    text_parts.append(part.get("text", ""))
                elif isinstance(part, str):
                    text_parts.append(part)
            content = " ".join(text_parts)

        # Simplify system prompt
        if role == "system":
            content = "You are a helpful personal assistant."

        messages.append({"role": role, "content": content})

    # Only send what MegaNova needs - force the model name
    clean_request = {
        "model": "meganova-ai/manta-flash-1.0",
        "messages": messages,
    }

    # Optional params that MegaNova supports
    if "temperature" in data:
        clean_request["temperature"] = data["temperature"]
    if "max_tokens" in data:
        clean_request["max_tokens"] = data["max_tokens"]
    if "top_p" in data:
        clean_request["top_p"] = data["top_p"]

    print("=== SENDING TO MEGANOVA ===")
    print(json.dumps(clean_request, indent=2, default=str)[:1000])

    try:
        response = requests.post(
            MEGANOVA_URL,
            headers={
                "Authorization": f"Bearer {API_KEY}",
                "Content-Type": "application/json"
            },
            json=clean_request,
            timeout=120
        )

        print(f"=== MEGANOVA RESPONSE: {response.status_code} ===")
        print(response.text[:500])

        result = response.json()

        # Clean up response - remove "Assistant: " prefix if present
        if "choices" in result:
            for choice in result["choices"]:
                if "message" in choice and "content" in choice["message"]:
                    content = choice["message"]["content"]
                    if content.startswith("Assistant: "):
                        choice["message"]["content"] = content[11:]
                    elif content.startswith("Assistant:"):
                        choice["message"]["content"] = content[10:]

        return result, response.status_code
    except Exception as e:
        print(f"=== ERROR: {e} ===")
        return {"error": str(e)}, 500

@app.route('/v1/models', methods=['GET'])
def list_models():
    return jsonify({
        "object": "list",
        "data": [
            {
                "id": "meganova-ai/manta-flash-1.0",
                "object": "model",
                "owned_by": "meganova"
            }
        ]
    })

@app.route('/health', methods=['GET'])
def health():
    return {"status": "ok"}

if __name__ == '__main__':
    print("Starting MegaNova proxy on http://127.0.0.1:4000")
    print(f"Using API key: {API_KEY[:10]}...")
    app.run(host='127.0.0.1', port=4000, debug=True)
