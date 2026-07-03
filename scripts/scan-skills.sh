#!/usr/bin/env bash
# scan-skills.sh — 扫描已安装的 Skill，按"体检优先级"排序，输出分诊表。
# 用法: bash scan-skills.sh [skills_dir]
# 默认扫描 ~/.claude/skills；可传入自定义目录。
#
# 说明：文件系统拿不到真实"使用频率"，所以这里用可移植的代理信号：
#   - 主文件行数（越长越可能臃肿 = 越值得体检）
#   - 是否已拆出 references/（没拆 + 主文件长 = 高风险）
#   - 最近修改时间（近期改过 = 活跃维护，大概率高频）
# 最终由用户确认"实际最常用哪几个"，脚本只做排序和提示。

set -euo pipefail

SKILLS_DIR="${1:-$HOME/.claude/skills}"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "❌ 找不到 Skills 目录: $SKILLS_DIR"
  echo "   请传入正确路径: bash scan-skills.sh /path/to/skills"
  exit 1
fi

echo "🩺 Skill Doctor 分诊扫描：$SKILLS_DIR"
echo ""
printf "%-28s %8s %6s %10s   %s\n" "SKILL" "行数" "拆分" "近改(天)" "体检优先级"
printf "%s\n" "------------------------------------------------------------------------------"

now=$(date +%s)

# 收集数据到临时文件，便于按优先级排序
tmp=$(mktemp)
for d in "$SKILLS_DIR"/*/; do
  md="$d/SKILL.md"
  [ -f "$md" ] || continue
  name=$(basename "$d")
  lines=$(wc -l < "$md" | tr -d ' ')
  if [ -d "$d/references" ]; then split="有"; else split="无"; fi

  # 跨平台取 mtime（Linux: -c %Y；macOS: -f %m）
  mtime=$(stat -c %Y "$md" 2>/dev/null || stat -f %m "$md" 2>/dev/null || echo "$now")
  days=$(( (now - mtime) / 86400 ))

  # 体检优先级评分：行数为主，未拆分加权
  score=$lines
  [ "$split" = "无" ] && score=$(( score + 100 ))

  printf "%d\t%s\t%s\t%s\t%s\n" "$score" "$name" "$lines" "$split" "$days" >> "$tmp"
done

# 按 score 降序输出，并给出建议标记
sort -rn "$tmp" | while IFS=$'\t' read -r score name lines split days; do
  flag=""
  if [ "$lines" -gt 200 ]; then flag="🔴 强烈建议";
  elif [ "$lines" -gt 120 ]; then flag="🟠 建议";
  elif [ "$split" = "无" ] && [ "$lines" -gt 80 ]; then flag="🟡 可看看";
  else flag="🟢 健康"; fi
  printf "%-28s %8s %6s %10s   %s\n" "$name" "$lines" "$split" "$days" "$flag"
done
rm -f "$tmp"

echo ""
echo "提示：行数 = 主文件长度；拆分 = 是否已有 references/；近改 = 距上次修改天数。"
echo "🔴>200行 / 🟠>120行 通常最该体检。请确认你实际最常用哪几个，再决定体检对象。"
