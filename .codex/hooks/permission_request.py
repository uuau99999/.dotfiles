#!/usr/bin/env python3
"""Codex permission_request hook: 黑名单 deny → 白名单 allow → 其余交给用户。

复合命令(&& || | ;)逐段校验首个命令词,全部命中白名单才整体 allow;
任意一段不在白名单则不输出决策(交还正常审批流程)。
"""
import json
import re
import shlex
import sys

# 危险命令黑名单(须与 pre_tool_use_policy.py 保持一致)
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

SAFE_COMMANDS = {
    # 文件/查看
    'ls', 'pwd', 'cat', 'head', 'tail', 'wc', 'file', 'stat', 'du', 'df', 'tree',
    # shell 内建/文本处理
    'echo', 'printf', 'test', 'true', 'false', 'cd', 'export',
    'sed', 'awk', 'cut', 'sort', 'uniq', 'comm', 'tr', 'basename', 'dirname',
    'grep', 'rg', 'find', 'fd', 'which', 'type', 'whereis', 'xargs', 'tee', 'read',
    # 时间/环境
    'date', 'env', 'sleep',
    # 版本控制/包管理
    'git', 'npm', 'pnpm', 'npx', 'yarn', 'jq',
    # 运行时/工具链
    'node', 'python', 'python3', 'tsx', 'ts-node',
    'eslint', 'prettier', 'tsc', 'vue-tsc', 'oxlint', 'webpack', 'vite', 'turbo',
    'go', 'goimports', 'cargo', 'rustc',
    # nix / 本仓库高频
    'nix', 'darwin-rebuild', 'home-manager', 'brew',
    # 容器
    'docker', 'docker-compose', 'podman',
    # 文件操作(破坏性变体由黑名单兜底)
    'mkdir', 'touch', 'cp', 'mv', 'chmod', 'ln', 'tar', 'zip', 'unzip', 'gzip', 'gunzip',
    # 进程/网络(危险变体由黑名单兜底)
    'lsof', 'ps', 'pgrep', 'pkill', 'kill',
    'curl', 'wget', 'ssh', 'scp', 'rsync',
}

ASSIGNMENT_RE = re.compile(r'^[A-Za-z_][A-Za-z0-9_]*=.*$')
# 复合命令分隔符:&& || | ; &(切分原始字符串,不依赖 shlex 切词)
SEGMENT_SPLIT_RE = re.compile(r'\|\||&&|[|;&]')
# 前导包装命令:跳过后取真正的命令词
WRAPPERS = {'env', 'command', 'nohup', 'time', 'sudo', 'exec'}


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


def segment_first_command(segment: str) -> str | None:
    """取一段命令的首个真正命令词;空段返回 None,无法解析返回 ''。"""
    try:
        tokens = shlex.split(segment, posix=True)
    except ValueError:
        return ''
    if not tokens:
        return None
    for token in tokens:
        if ASSIGNMENT_RE.match(token):
            continue  # 环境变量赋值前缀
        name = token.rsplit('/', 1)[-1]
        if name in WRAPPERS:
            continue  # 包装命令,继续找真正命令词
        return name
    return None  # 整段都是赋值/包装,无实际命令


def all_segments_safe(command: str) -> bool:
    """按分隔符拆分复合命令,要求每一段的首个命令词都在白名单。"""
    segments = SEGMENT_SPLIT_RE.split(command)
    saw_command = False
    for segment in segments:
        if not segment.strip():
            continue
        name = segment_first_command(segment)
        if name is None:
            continue  # 空段(如尾随分隔符)
        if name == '' or name not in SAFE_COMMANDS:
            return False
        saw_command = True
    return saw_command


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    command = ((payload.get('tool_input') or {}).get('command')) or ''
    if not command.strip():
        return 0

    for pattern in DANGEROUS_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return emit('deny', f'Dangerous command blocked: matches {pattern}')

    if all_segments_safe(command):
        return emit('allow')

    return 0


if __name__ == '__main__':
    raise SystemExit(main())
