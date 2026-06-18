#!/bin/bash
set -euo pipefail

REPO_NAME="summer-scene-research-report"
DEPLOY_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! gh auth status >/dev/null 2>&1; then
  echo "请先登录 GitHub："
  gh auth login -h github.com -p https -w
fi

USER="$(gh api user -q .login)"
cd "$DEPLOY_DIR"

if [ ! -d .git ]; then
  git init -b main
  git add .
  git commit -m "Deploy summer scene research report"
fi

if gh repo view "$USER/$REPO_NAME" >/dev/null 2>&1; then
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/$USER/$REPO_NAME.git"
  git push -u origin main --force
else
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
fi

gh api "repos/$USER/$REPO_NAME/pages" -X POST \
  -f build_type=legacy \
  -f source[branch]=main \
  -f source[path]=/ 2>/dev/null || \
gh api "repos/$USER/$REPO_NAME/pages" -X PUT \
  -f build_type=legacy \
  -f source[branch]=main \
  -f source[path]=/

echo ""
echo "部署完成！"
echo "在线地址：https://$USER.github.io/$REPO_NAME/"
echo "（GitHub Pages 首次生效可能需要 1–3 分钟）"
