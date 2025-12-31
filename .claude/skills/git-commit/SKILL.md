---
name: git-commit

description: 使用中文提交当前工作区变更，遵循约定式提交格式
---

# Git Commit 技能

使用中文提交当前工作区变更。

## 使用方法

使用 `/git-commit` 调用

## 指令

调用此技能时：

1. **检查工作区状态**

   - 运行 `git status` 查看所有修改、添加和删除的文件
   - 运行 `git diff` 查看未暂存的变更
   - 运行 `git diff --cached` 查看已暂存的变更
   - 运行 `git log --oneline -5` 查看最近的提交信息风格

2. **暂存变更（如需要）**

   - 如果有未暂存的变更，询问用户是暂存所有变更还是选择特定文件
   - 使用 `git add .` 暂存所有变更，或使用 `git add <files>` 暂存特定文件

3. **生成提交信息（必须使用中文）**

   - 使用 `git diff --cached` 分析变更
   - 生成约定式提交信息，格式如下：
     - `feat:` 新功能
     - `fix:` 修复 bug
     - `docs:` 文档变更
     - `style:` 格式化变更
     - `refactor:` 代码重构
     - `test:` 添加测试
     - `chore:` 维护任务
   - 第一行不超过 72 字符
   - 如果变更复杂，添加空行和详细描述
   - **提交信息必须使用中文编写**
   - 遵循仓库现有的提交信息风格（如果可检测）

4. **确认并提交**

   - 向用户展示生成的提交信息
   - 询问确认或允许编辑
   - 执行 `git commit -m "<message>"`

5. **可选：推送到远程仓库**

   - 询问用户是否要推送提交
   - 如果是，运行 `git push`

## 示例交互

```
分析变更...

已暂存的变更：
- Modified: src/components/Button.tsx
- Added: src/utils/helpers.ts
- Deleted: src/old/deprecated.ts

生成的提交信息：
---
feat: 添加按钮组件和工具函数

- 添加新的按钮组件，包含悬停效果
- 创建 helpers.ts 工具函数文件
- 移除废弃代码
---

确认提交？[Y/n/edit]
```

## 注意事项

- 提交前始终展示变更
- 没有用户确认不得提交
- 不要提交可能包含密钥的文件（.env、credentials 等）
- **提交信息必须使用中文编写**
