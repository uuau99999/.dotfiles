---
name: git-commit

description: Commit current workspace changes with auto-generated commit messages following conventional commit format.
---

# Git Commit Skill

Commit current workspace changes with auto-generated commit messages.

## Usage

Invoke with: `/git-commit`

## Instructions

When this skill is invoked:

1. **Check working directory status**

   - Run `git status` to see all modified, added, and deleted files
   - Run `git diff` to see unstaged changes
   - Run `git diff --cached` to see staged changes
   - Run `git log --oneline -5` to see recent commit message style

2. **Stage changes if needed**

   - If there are unstaged changes, ask user whether to stage all changes or select specific files
   - Use `git add .` for all changes or `git add <files>` for specific files

3. **Generate commit message**

   - Analyze the changes using `git diff --cached`
   - Generate a conventional commit message following this format:
     - `feat:` for new features
     - `fix:` for bug fixes
     - `docs:` for documentation changes
     - `style:` for formatting changes
     - `refactor:` for code refactoring
     - `test:` for adding tests
     - `chore:` for maintenance tasks
   - Keep the first line under 72 characters
   - Add a blank line and detailed description if changes are complex
   - Follow the repository's existing commit message style if detectable

4. **Confirm and commit**

   - Show the generated commit message to the user
   - Ask for confirmation or allow editing
   - Execute `git commit -m "<message>"`

5. **Optional: Push to remote**

   - Ask if user wants to push the commit
   - If yes, run `git push`

## Example Interaction

```
Analyzing changes...

Staged changes:
- Modified: src/components/Button.tsx
- Added: src/utils/helpers.ts
- Deleted: src/old/deprecated.ts

Generated commit message:
---
feat: add Button component and utility helpers

- Add new Button component with hover effects
- Create helpers.ts with common utility functions
- Remove deprecated code
---

Proceed with this commit? [Y/n/edit]
```

## Notes

- Always show changes before committing
- Never commit without user confirmation
- Do not commit files that may contain secrets (.env, credentials, etc.)
