''
  {
    "$schema": "https://opencode.ai/config.json",
    "permission": {
      "edit": "ask",
      "doom_loop": "ask",
      "bash": {
        "*": "ask",
        "ls *": "allow",
        "grep *": "allow",
        "find *": "allow",
        "git status": "allow",
        "npm run test": "allow",
        "npm test *": "allow"
      }
    },
    "provider": {
      "ollama": {
        "npm": "@ai-sdk/openai-compatible",
        "name": "Ollama",
        "options": {
          "baseURL": "http://localhost:11434/v1"
        },
        "models": {
          "gemma4:latest": {}
        }
      }
    }
  }
''
