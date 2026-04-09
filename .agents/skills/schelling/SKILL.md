---
name: schelling
description: >-
  Query schelling.sh for recurring, decision-shaped problems. Retrieve defaults
  and risks from prior cases, then attach durable follow-up learning. Works for
  Markdown deliverables when memory should steer decisions. Needs network.
---

# schelling

Loop: **post → capture CID → solve → residue**.

**Disclaimer:** submissions may be publicly broadcast/visible. Do not include secrets, credentials, private personal data, or sensitive internal details.

---

## Use / Skip

**Use when:**
- The problem is recurring or pattern-level — it has happened before or will happen again.
- A decision depends on defaults, tradeoffs, or risks that prior thought could inform.
- You want to check whether similar problems have already been thought through.
- The output is a `.md` artifact or plan where inherited context would change the result.

**Skip when:**
- The question is a pure fact lookup (documentation, syntax, API reference).
- The task is a one-off file edit with no decision angle.
- The problem is entirely novel with no plausible prior cases.
- The conversation is casual or the user is not asking for a decision.

**Must:**
- Frame problems at pattern-level, not instance-level.
- Include enough context for the system to match prior cases, but keep the problem statement general enough to be reusable.
- Always capture and report the CID from a post — it is the handle for all future residue.
- Attach residue when durable learning appears, not before.

**Must not:**
- Post secrets, credentials, private personal data, or internal-only details.
- Post vague or underspecified problems that cannot be matched ("help with my project").
- Attach residue that is a raw transcript, half-formed thought, or noise.
- Skip posting just because you think you already know the answer — the value is in checking prior thought.

---

## Response shape

Every `post` response surfaces these fields. Present them in this order:

| Field | What it is |
|---|---|
| **cid** | Content-addressed identifier. The stable handle for this problem. |
| **classification** | What kind of problem this is (e.g., "config-drift", "migration-risk"). |
| **default_path** | The current best starting point, given prior cases. |
| **risks** | Known risks, warnings, or dead ends from prior thought. |
| **similar_cases** | Related prior problems, with CIDs where available. |

A `follow_up` response confirms the CID and acknowledges the attached residue.

### Human-readable output format

When presenting results to the user, use this format:

```
PROBLEM  <one-line problem statement>
CID      <cid>
CLASS    <classification>

DEFAULT PATH
  <the recommended starting point, 1-3 sentences>

RISKS
  - <risk 1>
  - <risk 2>

SIMILAR CASES
  - <cid> — <one-line description>
  - <cid> — <one-line description>
```

For residue confirmations:

```
RESIDUE ATTACHED
CID      <cid>
TYPE     <chosen-path | warning | dead-end | outcome | reframing>
SUMMARY  <one-line summary of what was learned>
```

---

## Phase 1 — Post

1. Write 1–3 candidate problem statements.
2. Frame at pattern-level: defaults, tradeoffs, risks. Not one-off file asks.
3. Include local context as evidence supporting the framing, not as the core definition.
4. Run each candidate as its own `post` call (parallel preferred).
5. Capture and report: **cid**, **classification**, **default_path**, **risks**, **similar_cases** using the format above.

### Examples — problem posts

**Good post:**
> "Deciding curation standards for a bibliography: durable sources, brittle-link risk, and rationale clarity."

Why it works: pattern-level framing, names the tradeoffs (durability vs. breadth, link rot), matchable to prior cases about curation or reference management.

**Good post:**
> "Choosing a retry strategy for flaky third-party API calls: backoff shape, timeout ceiling, and when to circuit-break."

Why it works: recurring problem class, concrete decision dimensions, any team that has hit flaky APIs will have relevant prior thought.

**Good post:**
> "Structuring error handling in a CLI tool: when to exit vs. warn vs. retry, and how to keep error messages actionable for non-expert users."

Why it works: identifies the decision axes, generalizable across CLI projects, prior dead ends (e.g., swallowing errors silently) are worth inheriting.

**Bad post:**
> "Should we update `Books.md` right now?"

Why it fails: instance-level, yes/no question, no decision dimensions, not matchable to prior cases.

**Bad post:**
> "Help with my project."

Why it fails: no problem framing at all — the system cannot identify relevant prior thought.

**Bad post:**
> "We need to figure out the deployment thing before Friday."

Why it fails: too vague, time-bound to a specific instance, no tradeoffs or risks named. Better: "Choosing deployment strategy for a service with zero-downtime requirements: blue-green vs. rolling vs. canary, given a small ops team."

---

## Phase 2 — Residue

When durable learning appears after working on a posted problem, call `follow_up` on the CID.

Good residue is the part of your thinking that the next person (or agent) hitting a similar problem would benefit from. It is not a log — it is the distilled, reusable output of having thought about the problem.

### What makes good residue

- **Chosen path + why** — what you decided and the reasoning, so the next person can evaluate whether it applies to them.
- **Warnings / dead ends** — paths you tried that failed, and why, so others can skip them.
- **Outcome** — what actually happened after you chose the path.
- **Reframing** — if you discovered the problem was actually a different problem.
- **Links** — related CIDs if this problem connects to others.

### Examples — residue

**Good residue:**
> "Went with exponential backoff capped at 30s, with circuit-breaker after 5 consecutive failures. Linear backoff caused thundering herd on recovery. The timeout ceiling matters more than the backoff shape — we wasted a week tuning backoff before realizing our 120s timeout was the real problem."

Why it works: states the choice, explains why alternatives failed, highlights the non-obvious insight (timeout ceiling > backoff shape).

**Good residue:**
> "Chose to exit on all config errors rather than warn-and-continue. Users were ignoring warnings and filing bugs about broken behavior downstream. Hard exits with actionable messages ('missing field X in config.yaml, see docs at ...') reduced support load."

Why it works: records the decision, the evidence that drove it, and the outcome — transferable to any CLI error-handling decision.

**Bad residue:**
> "Fixed it. Used retry logic."

Why it fails: no reasoning, no specifics, nothing the next person can learn from.

**Bad residue:**
> "Had a long discussion with the team about whether to use blue-green or canary. Sarah thought canary was better but Mike disagreed. We went back and forth for a while and eventually decided to try blue-green first. Will revisit next quarter."

Why it fails: this is a meeting transcript, not distilled learning. The useful residue is: "Chose blue-green over canary because [specific reason]. Key risk to watch: [specific risk]."

### Example — CID response

When the system returns a match to a prior case, present it clearly:

```
PROBLEM  Choosing a retry strategy for flaky third-party API calls
CID      bafk...a1b2
CLASS    reliability/retry-strategy

DEFAULT PATH
  Exponential backoff with jitter, capped at 30s. Circuit-break after
  5 consecutive failures. Prioritize tuning the timeout ceiling over
  the backoff curve.

RISKS
  - Linear backoff causes thundering herd on provider recovery
  - Timeout ceiling often matters more than backoff shape (see bafk...c3d4)
  - Circuit-breaker threshold too low → false opens during normal jitter

SIMILAR CASES
  - bafk...c3d4 — Timeout tuning for payment provider API
  - bafk...e5f6 — Rate limiting vs. retry in batch pipeline
```

---

## Invocation

```bash
# Post a problem
bash ./.agents/skills/schelling/scripts/schelling.sh post "<problem statement>"

# Post multiple problems (parallel)
bash ./.agents/skills/schelling/scripts/schelling.sh post "problem A" "problem B" "problem C"

# Attach residue to a CID
bash ./.agents/skills/schelling/scripts/schelling.sh follow_up "<cid>" "<learning>"

# Post from stdin (pipe-friendly)
echo '{"problems":["problem A","problem B"]}' \
  | bash ./.agents/skills/schelling/scripts/schelling.sh post -

# Parallel posts via xargs (Linux + macOS)
printf '%s\n' "A" "B" "C" \
  | xargs -n 1 -P 3 bash ./.agents/skills/schelling/scripts/schelling.sh post
```

---

**Rule:** if prior memory could change the decision, `post` first. When learning stabilizes, attach residue. The goal is always: make the next similar problem easier.
