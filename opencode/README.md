# Global OpenCode Configuration

This directory contains the global configuration for `opencode` used in this environment.

## File Information
- **Config File:** [`opencode.json`](./opencode.json)
- **System Location:** `~/.config/opencode/opencode.json`

## Settings Breakdown
- **Permissions**:
  - Read/Search (read, glob, grep, list): Allowed
  - Web Access (webfetch): Allowed
  - File Editing (edit): Allowed
  - Shell Execution (bash): Ask for confirmation
- **Plugins**:
  - `opencode-gemini-auth@latest`: Auth provider for Gemini

## Custom Plugins

### Ghostty Notifications (`ghostty-osc9-notify.js`)
We use a custom plugin to make sure you never miss an alert from OpenCode.

- **What it does:** It sends a system notification whenever OpenCode finishes a task or needs your permission to proceed.
- **How it works:**
  1.  **macOS Notifications:** It tries to pop up a standard macOS notification banner (using `osascript`).
  2.  **Ghostty/Terminal Support:** If that fails or if you're in a remote session, it sends a special "OSC9" escape code. Terminals like Ghostty and iTerm2 recognize this code and will trigger their own notifications (e.g., bouncing the dock icon or showing a badge).
- **Files:**
  - Repo Copy: [`plugins/ghostty-osc9-notify.js`](./plugins/ghostty-osc9-notify.js)
  - Live System Path: `~/.config/opencode/plugins/ghostty-osc9-notify.js`
