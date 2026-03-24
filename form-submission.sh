#!/bin/bash

# Example of form submission behind reCAPTCHA
# Ensure you have set the AGENT_BROWSER_EXTENSIONS environment variable
# or use the --extension flag.

# 1. Navigate to the page with CapSolver extension loaded
agent-browser --extension ./capsolver-extension open https://example.com/contact

# 2. Get a snapshot to discover form elements
agent-browser snapshot -i

# 3. Fill in the form
# Use the @ref from the snapshot output
agent-browser fill @e1 "John Doe"
agent-browser fill @e2 "john@example.com"
agent-browser fill @e3 "Hello, I have a question about your services."

# 4. Wait for CapSolver to resolve the CAPTCHA
# The extension will automatically detect and solve the CAPTCHA
agent-browser wait 30000

# 5. Submit — the CAPTCHA token is already injected
agent-browser click @e4
