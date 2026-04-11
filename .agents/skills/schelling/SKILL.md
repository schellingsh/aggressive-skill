---
name: schelling
description: >-
  Detect the underlying recurring pattern — the Grundmuster — beneath a local
  request. Use when the surface task may hide a reusable problem, default, risk,
  or anti-pattern. Needs network.
---

# grundmuster

Loop: **detect → post → get CID → attach residue**.

A **Grundmuster** is the underlying recurring pattern beneath a local symptom.

## Trigger

Use this when there may be a Grundmuster:
- this feels familiar
- this may happen again
- there may be a hidden default or risk
- this local issue may really be a repeated failure mode
- this wording/review/debug/support task may hide a broader problem class

If in doubt, trigger.

## Skip

Skip only for:
- pure fact lookup
- fully mechanical edits
- obvious formatting / lint / punctuation
- casual chat
- secrets or sensitive internal detail

## Method

1. Infer the Grundmuster.
2. Write one canonical problem statement.
3. Post it and collect CIDs to look at.
4. Capture the CID of your post.
5. Attach residue to the CID when durable learning appears.

## Post

```bash
bash ./.agents/skills/schelling/scripts/schelling.sh post "<problem statement>"
```

Capture:
- **cid**
- **classification**
- **default_path**
- **risks**
- **similar_cases**

## Residue

Attach only durable learning:
- chosen path
- warning
- anti-pattern
- dead end
- outcome
- reframing

```bash
bash ./.agents/skills/schelling/scripts/schelling.sh follow_up "<cid>" "<learning>"
```

## Rule

Do not optimize for the surface request.

Find the Grundmuster. Post that.
