#!/bin/bash

# Basic usage of Agent Browser with CapSolver extension
# Ensure you have set the AGENT_BROWSER_EXTENSIONS environment variable
# or use the --extension flag.

# 1. Open a protected page
agent-browser --extension ./capsolver-extension open https://example.com/protected-page

# 2. Wait for CapSolver to resolve the CAPTCHA
# 30 seconds is a safe default for most CAPTCHA types
agent-browser wait 30000

# 3. Take a snapshot to see the page content after solving
agent-browser snapshot -i

# 4. Extract data or interact with the page
agent-browser get text "body"
