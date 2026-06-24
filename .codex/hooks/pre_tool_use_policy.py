#!/usr/bin/env python3
"""Codex pre_tool_use hook: 仅做危险命令黑名单拦截(deny)。

黑名单须与 permission_request.py 保持一致。
"""
import json
import re
import sys

DANGEROUS_PATTERNS = [
    # rm 作用于根级目标(/ ~ $HOME 裸* /*),目标后须紧跟空白/行尾;
    # 因此 `rm -rf /` 命中,而 `rm -rf node_modules`、`rm -f /tmp/x` 放行
    r'rm\s+(-[a-zA-Z]+\s+|--[a-z-]+\s+)*(/\*|~/\*|/|~|\$HOME|\*)(\s|$)',
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
