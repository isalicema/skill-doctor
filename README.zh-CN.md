<!-- Language: [English](./README.md) | **简体中文** -->

[English](./README.md) | **简体中文**

# 🩺 Skill Doctor

> 一个 Claude Code 的元技能（meta-skill）：给你的**其他 Skill** 做健康体检，并明确告诉你哪里该瘦身。

> [!NOTE]
> **本工具受 Matt Pocock 启发**，完全基于他在演讲 ***Building Great Agent Skills: The Missing Manual***（AI Engineer）中分享的方法论构建。核心思路——*谁触发 → 结构 → deletion test*、leading words、以及 deletion test 本身——皆源自他的分享。Skill Doctor 只是把这套方法固化成一个可运行的 Skill。
> 📺 **观看原始演讲：** https://www.youtube.com/watch?v=UNzCG3lw6O0

Skill Doctor 用 Matt Pocock 演讲 [*Building Great Agent Skills: The Missing Manual*](https://www.youtube.com/watch?v=UNzCG3lw6O0) 里的方法，评审任意一个 Claude Code Skill。它**只做诊断**——除非你明确要求，否则绝不修改你的任何文件。

如果你的 `SKILL.md` 越写越长、规则越加越多、Agent 却越来越不听话——你大概率掉进了 Pocock 说的 **"Skill Hell"（技能地狱）**。Skill Doctor 帮你把一份臃肿的 Skill 变回**可执行的入口**。

---

## 为什么需要它？

Skill 一出问题，开发者就往里加规则。几轮下来，`SKILL.md` 变成一个谁都不敢删的杂物柜。解药不是**更多规则**，而是一次评审：

> **谁触发 → 结构 → 删减（deletion test）**

Skill Doctor 就跑这套评审，给你一份按优先级排序的体检报告。

---

## 安装

把 `skill-doctor/` 文件夹拷进你的 Claude Code skills 目录：

```bash
git clone https://github.com/isalicema/skill-doctor.git
cp -r skill-doctor ~/.claude/skills/
```

然后直接对 Claude Code 说：

- **"哪些 skill 该体检？"** → 运行 onboarding 扫描
- **"体检 my-skill"** → 输出完整体检报告
- **"改造 my-skill"** → 应用修改（**仅在你同意之后**）

---

## 它检查的三道关卡

| 关卡 | 追问 | 抓什么 |
|------|------|--------|
| **1. 谁触发** | 自动还是手动？触发语一致吗？ | 高影响却设成自动触发；触发语散落在多个文件；上下文成本臃肿 |
| **2. 结构** | 步骤和参考材料混在一起了吗？ | 模板/术语表/长清单焊死在主文件里。目标：**主文件十分钟读得完** |
| **3. Deletion test** | 删掉这行——Agent 行为会变吗？ | **No-op**（看着有用、实则不改变行为）、重复、沉积物。同时保护真正引导行为的 *leading words* |

---

## 🔒 两道同意门（安全第一）

Skill Doctor 刻意设计成**手动触发**，未经许可绝不碰你的文件：

1. **门一 · 体检** —— 你选定一个 skill 后，它**只读、只出报告**，不做任何修改。
2. **门二 · 改造** —— 除非你明确说 *"改造 / 优化 / 动手改"*，否则它不会改动任何一个文件。

> 报告 **≠** 授权改动。哪怕问题很明显，它也停在建议、等你拍板。

任何改造之前，它会先备份目标（`cp SKILL.md SKILL.md.bak-<日期>`），改完再跑一次关键词存活检查，确保搬家过程中什么都没丢。

---

## Onboarding：不知道从哪个 skill 下手？

跑一下分诊扫描，按体检优先级给你已装的 skill 排序：

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

它按主文件长度、是否已拆出参考文件、以及最近修改时间来排序。（文件系统看不到**真实**使用频率，所以它会让你确认自己实际最常用哪几个，再推荐体检。）

---

## 实战案例：给 `collection-manager` 瘦身

一个真实的 before/after。`collection-manager` 是一个用四步流程保存并总结文章的 skill。

**改造前 —— 111 行。** 四步流程本身没问题，但一段约 40 行的 Markdown 输出模板被直接贴在第 3 步中间，命名规范又是单独的结尾一节。步骤被参考材料淹没了。

**体检发现：**
- **① 入口** —— *真实的*触发语只写在一个单独的记忆文件里，没进 skill 的 `description`。入口真相被拆散在两处。
- **② 结构** 🔴 —— 输出模板（占全文约 40%）是参考材料，不是步骤。它只在*写的时候*才查，应该拆到旁边文件。
- **③ Deletion test** —— 第 3 步里有两行在重复"要提炼、别写读后感"同一个意思。但核心的 *leading* 句（"动笔前先读完全文"）确实改变了行为——**这些留着**。

**改造后 —— 57 行（−49%）。** 模板 + 命名规范移到 `references/template.md`；第 3 步只留三条干净的质量标准 + 一句指向。触发语补回 `description`。没有丢失任何 leading words。

```
collection-manager/
├── SKILL.md                 57 行  ← 步骤 + 一句指向
└── references/
    └── template.md          ← 输出格式，按需查阅
```

现在主文件重新变回**十分钟读得完**的*可执行入口*，而不是一篇长文档。

---

## 致谢

方法论：**Matt Pocock**，*Building Great Agent Skills: The Missing Manual*（[AI Engineer](https://www.youtube.com/watch?v=UNzCG3lw6O0)）。

由 **Machiwhale Studio** 🐋 作为元技能构建——是的，Skill Doctor 自己也通过了自己的体检（主文件不到 60 行，参考材料已拆出）。

## 许可证

[MIT](./LICENSE)
