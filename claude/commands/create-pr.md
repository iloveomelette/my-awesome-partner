---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*)
description: Create PR with well-structured description.
argument-hint: [draft] [parent-branch]
---

# Create PR Command

This command helps you create a pull request with a well-structured description.

## Usage

To create a pull request, just type:
```
/create-pr draft(optional) parent-branch(optional, default: develop)
```

## What This Command Does

1. Understand the changes made to the current branch.
2. If a PR template is defined in `.github/PULL_REQUEST_TEMPLATE.md`, understand its structure and requirements.
3. Plan the title and content of the PR based on the changes made.
4. Based on the arguments, create either a draft or regular PR against the specified parent branch (default: develop).
5. Open the created PR in the browser.
  - `gh pr view [<pr-number>] --web`

## gh command Examples

### Create a regular PR against develop(no argument)
Execute the following when no arguments are specified:

```
gh pr create -B develop -t "<PR Title>" -b "<PR Body>"
```

### Create a draft PR against develop
If `draft` is specified in $ARGUMENTS, execute the following:

```
gh pr create -B develop -d -t "<PR Title>" -b "<PR Body>"
```

### Create a regular PR against a parent branch
If an argument other than `draft` is specified in $ARGUMENTS, execute the following:

```
gh pr create -B parent-branch -t "<PR Title>" -b "<PR Body>"
```

### Create a draft PR against a parent branch
If both `draft` and a parent branch are specified in $ARGUMENTS, execute the following:

```
gh pr create -B parent-branch -d -t "<PR Title>" -b "<PR Body>"
```
