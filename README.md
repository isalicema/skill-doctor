# 🩺 Skill Doctor

> A meta-skill for Claude Code that gives your **other skills** a health checkup — and tells you exactly what to trim.

> [!NOTE]
> **Inspired by Matt Pocock.** Skill Doctor is built entirely on the method Matt Pocock shared in his talk ***Building Great Agent Skills: The Missing Manual*** (AI Engineer). All credit for the underlying approach — *who-triggers → structure → deletion test*, leading words, and the deletion test itself — goes to him. Skill Doctor just packages that method into a runnable skill.
> 📺 **Watch the original talk:** https://www.youtube.com/watch?v=UNzCG3lw6O0
>
> **本工具受 Matt Pocock 启发**，完全基于他在演讲《Building Great Agent Skills: The Missing Manual》中分享的方法论构建。核心思路（谁触发→结构→删减、leading words、deletion test）皆源自他的分享，Skill Doctor 只是把这套方法固化成一个可运行的 Skill。

Skill Doctor reviews any Claude Code Skill using the method from Matt Pocock's talk [*Building Great Agent Skills: The Missing Manual*](https://www.youtube.com/watch?v=UNzCG3lw6O0). It **diagnoses only** — it never edits your files unless you explicitly ask it to.

如果你的 `SKILL.md` 越写越长、规则越加越多、Agent 却越来越不听话 —— 你大概率掉进了 Pocock 说的 **"Skill Hell"**。Skill Doctor 帮你把一份臃肿的 Skill 变回**可执行的入口**。

---

## Why?

Developers keep adding rules when a skill misbehaves. A few rounds later, `SKILL.md` becomes a junk drawer nobody dares to delete from. The fix isn't *more* rules — it's a review:

> **谁触发 → 结构 → 删减**
> *Who triggers it → Structure → Deletion test*

Skill Doctor runs exactly that review and hands you a prioritized report.

---

## Install

Copy the `skill-doctor/` folder into your Claude Code skills directory:

```bash
git clone https://github.com/isalicema/skill-doctor.git
cp -r skill-doctor ~/.claude/skills/
```

Then just tell Claude Code:

- **"哪些 skill 该体检？"** / *"which skills need a checkup?"* → runs onboarding scan
- **"体检 my-skill"** / *"review my-skill"* → full checkup report
- **"改造 my-skill"** / *"refactor my-skill"* → applies fixes (only after you approve)

---

## The three gates it checks

| Gate | Question | What it catches |
|------|----------|-----------------|
| **1. Who triggers it** | Auto or manual? Is the trigger phrase consistent? | High-impact skills set to auto-trigger; trigger words scattered across files; context-cost bloat |
| **2. Structure** | Steps vs. reference material mixed together? | Templates / glossaries / long lists welded into the main file. Goal: **main file readable in 10 minutes** |
| **3. Deletion test** | Delete this line — does the agent's behavior change? | **No-ops** (looks useful, changes nothing), duplication, and sediment. Protects the *leading words* that actually steer behavior |

---

## 🔒 Two consent gates (safety first)

Skill Doctor is deliberately **manual-trigger** and never touches your files without permission:

1. **Gate 1 · Checkup** — once you pick a skill, it *only reads and reports*. No edits.
2. **Gate 2 · Refactor** — it will not change a single file until you explicitly say *"refactor / optimize / go ahead."*

> A report is **not** authorization to edit. Even when a problem is obvious, it stops at the recommendation and waits for you.

Before any refactor it backs up the target (`cp SKILL.md SKILL.md.bak-<date>`) and runs a keyword survival check afterwards, so nothing gets lost in the move.

---

## Onboarding: don't know where to start?

Run the triage scan to rank your installed skills by checkup priority:

```bash
bash ~/.claude/skills/skill-doctor/scripts/scan-skills.sh
```

```
SKILL                          行数   拆分  近改(天)   体检优先级
------------------------------------------------------------------
some-big-skill                  662    有       16     🔴 强烈建议
another-skill                   485    有       53     🔴 强烈建议
tidy-little-skill                56    无      109     🟢 健康
```

It ranks by main-file length, whether reference files have been split out, and recent edits. (The filesystem can't see *real* usage frequency, so it asks you to confirm which ones you actually use most before recommending a checkup.)

---

## Worked example: slimming a `collection-manager` skill

A real before/after. `collection-manager` is a skill that saves and summarizes articles in four steps.

**Before — 111 lines.** The four-step workflow was sound, but a ~40-line Markdown output template was pasted right into the middle of Step 3, and the naming rules were a separate trailing section. The steps were drowning in reference material.

**Checkup found:**
- **① Entry** — the *real* trigger phrase lived only in a separate memory file, not in the skill's `description`. Entry truth was split across two places.
- **② Structure** 🔴 — the output template (~40% of the file) is reference material, not a step. It's only consulted *while writing*, so it belongs in a side file.
- **③ Deletion test** — a couple of lines in Step 3 repeated the same "distill, don't summarize" idea. But the core *leading* lines ("read the whole thing before writing") genuinely changed behavior — **keep those**.

**After — 57 lines (−49%).** The template + naming rules moved to `references/template.md`; Step 3 kept three crisp quality standards plus one pointer. The trigger phrase was added back into `description`. No leading words were lost.

```
collection-manager/
├── SKILL.md                 57 lines  ← steps + one pointer
└── references/
    └── template.md          ← the output format, consulted on demand
```

The main file is now a **10-minute read** and an *executable entry point* again, instead of a long document.

---

## Credits

Method: **Matt Pocock**, *Building Great Agent Skills: The Missing Manual* ([AI Engineer](https://www.youtube.com/watch?v=UNzCG3lw6O0)).

Built by **Machiwhale Studio** 🐋 as a meta-skill — and yes, Skill Doctor passes its own checkup (main file under 60 lines, reference material split out).

## License

[MIT](./LICENSE)
