# Agent Browser CapSolver Integration

![Solve CAPTCHA with Vercel Agent Browser](https://assets.capsolver.com/prod/posts/agent-browser-capsolver/WFC38SHvWK8j-7e38eacf4a9fbcc37917a46f6a7ca175.webp)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Stars](https://img.shields.io/github/stars/vercel-labs/agent-browser?style=social)](https://github.com/vercel-labs/agent-browser/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/vercel-labs/agent-browser?style=social)](https://github.com/vercel-labs/agent-browser/network/members)

## Overview

This project provides a seamless and invisible CAPTCHA solving integration for [Vercel Agent Browser](https://github.com/vercel-labs/agent-browser) using the [CapSolver Chrome Extension](https://github.com/capsolver/capsolver-browser-extension). It enables AI agents and automated workflows to navigate CAPTCHA-protected websites without interruption, even in headless environments. By leveraging Agent Browser's native extension support, CapSolver automatically detects, solves, and injects CAPTCHA tokens in the background, allowing your automation scripts to remain clean and focused on core tasks.

## Features

- **Invisible CAPTCHA Solving**: CapSolver extension handles CAPTCHAs automatically and transparently.
- **Headless Mode Support**: Unlike many other solutions, this integration works flawlessly in both headed and headless browser modes, making it ideal for production pipelines, CI/CD, and serverless deployments.
- **Simplified Workflow**: No complex API orchestration or boilerplate code required. Just load the extension and add a wait command.
- **Broad CAPTCHA Compatibility**: Supports reCAPTCHA v2/v3, Cloudflare Turnstile, AWS WAF CAPTCHA, and more.
- **Built for AI Agents**: Leverages Agent Browser's AI-friendly features like semantic locators and snapshot-ref workflow.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Before you begin, ensure you have the following installed:

- **Vercel Agent Browser**: Install globally via npm: `npm install -g agent-browser`
- **Node.js 16+**: Required for npm installation.
- **A CapSolver account**: [Sign up here](https://www.capsolver.com/?utm_source=blog&utm_medium=article&utm_campaign=agent-browser-capsolver) to get your API key.

### Installation

1.  **Install Agent Browser**:

    ```bash
    npm install -g agent-browser
    agent-browser install # Download Chrome for Testing (first time only)
    ```

    *Alternative installation methods (macOS Homebrew, Cargo for Rust) are available in the [Agent Browser documentation](https://github.com/vercel-labs/agent-browser).* On Linux, include system dependencies:

    ```bash
    agent-browser install --with-deps
    ```

2.  **Download the CapSolver Chrome Extension**:

    Download `CapSolver.Browser.Extension-chrome-v1.17.0.zip` from the [CapSolver Chrome Extension v1.17.0 release page](https://github.com/capsolver/capsolver-browser-extension/releases/tag/v.1.17.0).

    Extract the zip file to a dedicated directory, for example, `~/capsolver-extension`:

    ```bash
    mkdir -p ~/capsolver-extension
    unzip CapSolver.Browser.Extension-chrome-v*.zip -d ~/capsolver-extension/
    ```

    Verify the extraction by checking for `manifest.json`:

    ```bash
    ls ~/capsolver-extension/manifest.json
    ```

3.  **Configure Your CapSolver API Key**:

    Open the extension config file at `~/capsolver-extension/assets/config.js` and replace the `apiKey` value with your CapSolver API key:

    ```javascript
    export const defaultConfig = {
      apiKey: 'CAP-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', // ← your key here
      useCapsolver: true,
      // ... rest of the config
    };
    ```

    You can find your API key on your [CapSolver dashboard](https://dashboard.capsolver.com/passport/login/?utm_source=blog&utm_medium=article&utm_campaign=agent-browser-capsolver).

## Usage

Once setup is complete, using CapSolver with Agent Browser is straightforward. Simply add the `--extension` flag pointing to your extracted CapSolver extension directory and a `wait` command after navigating to CAPTCHA-protected pages.

### Launching Agent Browser with the CapSolver Extension

```bash
agent-browser --extension ~/capsolver-extension open https://example.com/protected-page
```

For **headed mode** (to visually see the browser):

```bash
agent-browser --extension ~/capsolver-extension --headed open https://example.com/protected-page
```

### The Golden Rule: Don't write CAPTCHA-specific logic.

Just add a wait after navigating to CAPTCHA-protected pages, and let the extension do its work.

### Examples

See the `examples/` directory for practical use cases:

- `examples/basic-usage.sh`: Basic navigation and data extraction.
- `examples/form-submission.sh`: Submitting forms behind reCAPTCHA.

#### Example: Form Submission Behind reCAPTCHA

```bash
# Navigate to the page with CapSolver extension loaded
agent-browser --extension ~/capsolver-extension open https://example.com/contact

# Get a snapshot to discover form elements
agent-browser snapshot -i
# Output:
# - textbox "Name" [ref=e1]
# - textbox "Email" [ref=e2]
# - textbox "Message" [ref=e3]
# - button "Submit" [ref=e4]

# Fill in the form
agent-browser fill @e1 "John Doe"
agent-browser fill @e2 "john@example.com"
agent-browser fill @e3 "Hello, I have a question about your services."

# Wait for CapSolver to resolve the CAPTCHA (e.g., 30 seconds)
agent-browser wait 30000

# Submit — the CAPTCHA token is already injected by the extension
agent-browser click @e4
```

### Recommended Wait Times

| CAPTCHA Type             | Typical Solve Time | Recommended Wait |
| :----------------------- | :----------------- | :--------------- |
| reCAPTCHA v2 (checkbox)  | 5-15 seconds       | 30-60 seconds    |
| reCAPTCHA v2 (invisible) | 5-15 seconds       | 30 seconds       |
| reCAPTCHA v3             | 3-10 seconds       | 20-30 seconds    |
| Cloudflare Turnstile     | 3-10 seconds       | 20-30 seconds    |

**Tip**: When in doubt, use 30 seconds. It's better to wait a bit longer than to submit too early. The extra time doesn't affect the result.

## How It Works Behind the Scenes

When Agent Browser runs with the CapSolver extension loaded, the following sequence of events occurs:

```
Your Agent Browser Commands
───────────────────────────────────────────────────
agent-browser --extension       ──►  Chrome launches with extension
  ~/capsolver-extension
  open https://...
                                           │
                                           ▼
                               ┌─────────────────────────────┐
                               │  Page with CAPTCHA widget     │
                               │                               │
                               │  CapSolver Extension:         │
                               │  1. Content script detects    │
                               │     CAPTCHA on the page       │
                               │  2. Service worker calls      │
                               │     CapSolver API             │
                               │  3. Token received            │
                               │  4. Token injected into       │
                               │     hidden form field         │
                               └─────────────────────────────┘
                                           │
                                           ▼
agent-browser wait 30000         Extension resolves CAPTCHA...
                                           │
                                           ▼
agent-browser snapshot -i        Agent Browser reads elements
agent-browser click @e2          Form submits WITH valid token
                                           │
                                           ▼
                               "Verification successful!"
```

### Extension Loading Mechanism

Chrome starts with the CapSolver extension loaded (using `--headless=new` in headless mode, which supports Manifest V3 extensions). The extension activates, its service worker starts, and content scripts inject into every page. On pages with CAPTCHAs, the content script detects the widget, calls the CapSolver API, and injects the solution token into the page. Agent Browser then operates normally, with CAPTCHAs already handled.

## Configuration Reference

### CLI Flags

```bash
agent-browser \
  --extension ~/capsolver-extension \
  --headed \
  --session-name my-session \
  --profile ./browser-data \
  open https://example.com
```

### Environment Variables

You can set the extension path as an environment variable to avoid repeating the `--extension` flag:

```bash
export AGENT_BROWSER_EXTENSIONS=~/capsolver-extension
# Now every command automatically loads the extension
agent-browser open https://example.com
agent-browser wait 30000
agent-browser snapshot -i
```

### Config File (`agent-browser.json`)

Create an `agent-browser.json` in your project directory for persistent defaults:

```json
{
  "extension": ["~/capsolver-extension"],
  "sessionName": "capsolver-integration",
  "headed": false,
  "profile": "./browser-data"
}
```

| Option                       | Description                                                                                                                            |
| :--------------------------- | :------------------------------------------------------------------------------------------------------------------------------------- |
| `--extension <path>`         | Path to unpacked CapSolver extension directory containing `manifest.json`. Repeatable for multiple extensions.                         |
| `--headed`                   | Show browser window for visual debugging. Extensions work in both modes.                                                               |
| `--session-name <name>`      | Auto-save/restore cookies and localStorage across browser restarts.                                                                    |
| `--profile <path>`           | Persistent browser profile directory (cookies, IndexedDB, cache).                                                                      |
| `AGENT_BROWSER_EXTENSIONS`   | Environment variable alternative to `--extension` flag. Comma-separated paths for multiple extensions.                                 |

The CapSolver API key is configured directly in the extension's `assets/config.js` file (see [Step 3: Configure Your CapSolver API Key](#step-3-configure-your-capsolver-api-key)).

## Troubleshooting

### Extension Not Loading

**Symptom**: CAPTCHAs aren't being solved automatically.

**Possible causes:**
- Wrong extension path — ensure `manifest.json` exists in the specified directory.
- Extension not compatible — use the Chrome version of the CapSolver extension (not Firefox).

**Solution**: Verify the path and test in headed mode to visually confirm:

```bash
# Verify manifest exists
ls ~/capsolver-extension/manifest.json

# Test in headed mode to visually confirm
agent-browser --extension ~/capsolver-extension --headed open chrome://extensions
```

### CAPTCHA Not Solved (Form Fails)

**Possible causes:**
- **Insufficient wait time** — Increase to 60 seconds.
- **Invalid API key** — Check your CapSolver dashboard.
- **Insufficient balance** — Top up your CapSolver account.
- **Extension not loaded** — See "Extension Not Loading" above.

**Debug with console logs:**

```bash
agent-browser --extension ~/capsolver-extension open https://example.com
agent-browser wait 30000
agent-browser console # Check for CapSolver messages
```

### Chrome Not Found

**Symptom**: `agent-browser` can't find a Chrome executable.

**Solution**: Run the install command to download Chrome for Testing:

```bash
agent-browser install
```

Or point to a custom Chrome executable:

```bash
agent-browser --executable-path /path/to/chrome open https://example.com
```

### Multiple Extensions

You can load multiple extensions by repeating the `--extension` flag:

```bash
agent-browser \
  --extension ~/capsolver-extension \
  --extension ~/another-extension \
  open https://example.com
```

## Best Practices

1.  **Use the `AGENT_BROWSER_EXTENSIONS` environment variable.** Set it once in your shell profile or CI config, and every `agent-browser` command automatically loads CapSolver without repeating the flag.
2.  **Always use generous wait times.** More wait time is always safer. The CAPTCHA typically resolves in 5-20 seconds, but network latency, complex challenges, or retries can add time. 30-60 seconds is the sweet spot.
3.  **Keep your automation scripts clean.** Don't add CAPTCHA-specific logic to your commands. The extension handles everything — your scripts should focus purely on navigation, interaction, and data extraction.
4.  **Monitor your CapSolver balance.** Each CAPTCHA resolution costs credits. Check your balance at [capsolver.com/dashboard](https://www.capsolver.com/dashboard) regularly to avoid interruptions.
5.  **Use session persistence for repeat visits.** Use `--session-name` or `--profile` to preserve cookies across runs. This can reduce CAPTCHA frequency since the site may recognize returning sessions.
6.  **Leverage headless mode in production.** Unlike Playwright, Agent Browser supports extensions in headless mode. No need for Xvfb or virtual displays on servers — just run your commands directly.

## FAQ

- **Do I need to write CAPTCHA-specific code?**
  No. The CapSolver extension works entirely in the background within Agent Browser's Chrome instance. Just add an `agent-browser wait 30000` before submitting forms, and the extension handles detection, solving, and token injection automatically.

- **Can I run this in headless mode?**
  Yes! This is a major advantage over Playwright-based solutions. Agent Browser uses Chrome's `--headless=new` mode, which supports Manifest V3 extensions. No Xvfb or virtual display required.

- **Do I need Playwright or Node.js?**
  No. Agent Browser is a standalone Rust binary. You only need Node.js for the `npm install` step. The browser daemon runs natively without any JavaScript runtime.

- **What CAPTCHA types does CapSolver support?**
  CapSolver supports reCAPTCHA v2 (checkbox and invisible), reCAPTCHA v3, Cloudflare Turnstile, AWS WAF CAPTCHA, and more. The extension automatically detects the CAPTCHA type and resolves it accordingly.

- **How much does CapSolver cost?**
  CapSolver offers competitive pricing based on CAPTCHA type and volume. Visit [capsolver.com](https://www.capsolver.com) for current pricing.

- **Is Vercel Agent Browser free?**
  Yes. Agent Browser is open source under the Apache 2.0 license. The CLI and all features are free to use. Visit the [GitHub repository](https://github.com/vercel-labs/agent-browser) for more details.

- **How long should I wait for the CAPTCHA to be solved?**
  For most CAPTCHAs, 30-60 seconds is sufficient. The actual solve time is typically 5-20 seconds, but adding extra buffer ensures reliability. When in doubt, use 30 seconds via `agent-browser wait 30000`.

- **Can I use this with AI agents?**
  Absolutely. Agent Browser was built specifically for AI agents. Use `--json` for machine-readable output, the snapshot-ref workflow for deterministic element selection, and command chaining for efficient multi-step automation. The CapSolver extension runs transparently alongside your agent's commands.

## Contributing

We welcome contributions! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to get started.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For support or questions, please visit [CapSolver](https://www.capsolver.com) or the [Vercel Agent Browser GitHub repository](https://github.com/vercel-labs/agent-browser).

---

*This README is generated and maintained by Manus AI.*
