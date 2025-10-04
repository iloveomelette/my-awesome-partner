# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository manages instructions and prompts for AI tools, including Claude Code commands and agents. It's a curated collection of community-created resources for AI-assisted development.

## Repository Structure

- `claude/commands/`: Custom slash commands for Claude Code
  - Each command is a markdown file with YAML frontmatter defining metadata (argument-hint, description, model)
  - Commands are invoked via `/command-name` in Claude Code
- `claude/templates/`: Reusable templates for prompts and guidelines (e.g., coding style guides)
- `claude/agents/`: Custom agents for Claude Code (planned/future)
- `github-copilot/`: GitHub Copilot-related resources (planned)

## Working with Commands

When creating or modifying command files in `claude/commands/`:
- Use YAML frontmatter with required fields:
  - `argument-hint`: Description of expected arguments
  - `description`: What the command does
  - `model`: Which Claude model to use (e.g., `claude-opus-4-5`, `claude-sonnet-4-5`)
- Place the command prompt/instructions after the frontmatter
- File name determines the command name (e.g., `review-ruby.md` → `/review-ruby`)

## Key Principles

- This is a collection/curation repository - content is typically adapted from community sources
- Focus on reusable AI prompts and instructions rather than executable code
- Attribution to original sources is maintained in README.md
