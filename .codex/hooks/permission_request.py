#!/usr/bin/env python3
import json
import re
import shlex
import sys

DANGEROUS_PATTERNS = [
    r'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|--force\s+)*(\/|~|\$HOME|\*)',
    r'rm\s+-[a-zA-Z]*r[a-zA-Z]*f',
    r'git\s+push\s+.*(-f|--force)',
    r'git\s+reset\s+--hard',
    r'git\s+clean\s+-[a-zA-Z]*f',
    r'git\s+checkout\s+\.',
    r'git\s+restore\s+\.',
    r'chmod\s+777',
    r'mkfs\.',
    r'dd\s+if=',
    r':\(\)\s*\{.*\|.*&\s*\}\s*;',
    r'sudo\s+(rm|shutdown|reboot|mkfs|dd|chmod)',
    r'>\s*/dev/(sd|nvme|disk)',
    r'(curl|wget)\s+.*\|\s*(ba)?sh',
    r'\bshutdown\b',
    r'\breboot\b',
    r'\binit\s+0\b',
    r'mv\s+.*\s+/dev/null',
    r'echo\s+.*>\s*/etc/',
]

SAFE_COMMANDS = {
    'ls', 'pwd', 'cat', 'head', 'tail', 'wc', 'file', 'stat', 'du', 'df',
    'echo', 'printf', 'test', 'true', 'false',
    'grep', 'rg', 'find', 'fd', 'which', 'type', 'whereis',
    'tree', 'sort', 'uniq', 'diff', 'comm', 'xargs', 'tee', 'date', 'env',
    'git', 'npm', 'pnpm', 'npx', 'yarn',
    'node', 'python', 'python3', 'tsx', 'ts-node',
    'eslint', 'prettier', 'tsc', 'vue-tsc', 'webpack', 'vite', 'turbo',
    'docker', 'docker-compose', 'podman',
    'mkdir', 'touch', 'cp', 'mv', 'chmod', 'tar', 'zip', 'unzip',
    'lsof', 'ps', 'pgrep', 'pkill', 'kill',
    'curl', 'wget', 'ssh', 'scp',
}

ASSIGNMENT_RE = re.compile(r'^[A-Za-z_][A-Za-z0-9_]*=.*$')


def emit(decision: str, message: str | None = None) -> int:
    payload = {
        'hookSpecificOutput': {
            'hookEventName': 'PermissionRequest',
            'decision': {
                'behavior': decision,
            },
        }
    }
    if message:
        payload['hookSpecificOutput']['decision']['message'] = message
    json.dump(payload, sys.stdout)
    sys.stdout.write('\n')
    return 0


def first_command(command: str) -> str:
    try:
        tokens = shlex.split(command, posix=True)
    except ValueError:
        return ''

    skip = {'env', 'command'}
    for token in tokens:
        if token in {'|', '||', '&&', ';'}:
            break
        if ASSIGNMENT_RE.match(token):
            continue
        if token in skip:
            continue
        return token.rsplit('/', 1)[-1]
    return ''


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    command = ((payload.get('tool_input') or {}).get('command')) or ''
    for pattern in DANGEROUS_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return emit('deny', f'Dangerous command blocked: matches {pattern}')

    if first_command(command) in SAFE_COMMANDS:
        return emit('allow')

    return 0


if __name__ == '__main__':
    raise SystemExit(main())
