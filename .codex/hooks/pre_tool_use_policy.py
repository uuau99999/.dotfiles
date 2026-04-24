#!/usr/bin/env python3
import json
import re
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


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    command = ((payload.get('tool_input') or {}).get('command')) or ''
    for pattern in DANGEROUS_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            json.dump(
                {
                    'hookSpecificOutput': {
                        'hookEventName': 'PreToolUse',
                        'permissionDecision': 'deny',
                        'permissionDecisionReason': f'Dangerous command blocked: matches {pattern}',
                    }
                },
                sys.stdout,
            )
            sys.stdout.write('\n')
            return 0
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
