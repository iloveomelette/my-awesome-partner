# 🤖 My Awesome Partner

Manages instructions and prompts for AI.
Please share your awesome instructions or prompts.

I'm basically customizing things created by the community and pushing them to this repository.

## 🚀 Setup

This repository contains custom commands for Claude Code. To use them, run the setup script to create symlinks:

```bash
./scripts/setup-claude-links.sh
```

This will create symlinks from `claude/` directory to `~/.claude/`, making the custom commands available in Claude Code.

## 📁 Structure

```
.
├── README.md
├── claude
│   ├── commands # Custom slash commands
│   ├── templates # Custom templates e.g. style guidelines
│   └── agents (PLANNING) # Sub-agents
└── github-copilot (PLANNING)
    ├── instructions
    └── prompts
```

## 🎉 Special Thanks

- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
- [awesome-copilot](https://github.com/github/awesome-copilot)
