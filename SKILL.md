

---
name: harness-engineering
description: AI-native engineering operating system for making projects agent-navigable, constraint-driven, and self-improving. Includes runtime dispatching, task contracts, policy enforcement, and role-based execution.
---

# Harness Engineering OS (v1.0)

## Core Philosophy

> Transform AI usage from prompt-based interaction into a verifiable, constraint-driven system.

### Key Principles

- Agents have no memory → the repository is the only source of truth
- Do not instruct → enable discovery through structure
- Do not rely on review → enforce via mechanical constraints
- Do not assume → define explicit task contracts

---

## System Architecture

Harness OS consists of:

1. Navigation → `AGENT.md`
2. Knowledge Base → `harness/docs/`
3. Task Model → `harness/tasks/`
4. Runtime → `harness/runtime/`
5. Policy Engine → `scripts/`
6. Roles → `harness/roles/`
7. Feedback Loop → lint + score + evolution

---

## Directory Structure

```
harness/
  workflow.md

  docs/
    arch/
      invariants.md
      boundaries.md
    pm/
      product-overview.md
    rd/
      dev-conventions.md
      pitfalls.md
    qa/
      quality-checklist.md
      known-issues.md

  roles/
    product-manager.md
    product-reviewer.md
    architect.md
    architecture-reviewer.md
    coder.md
    code-reviewer.md
    qa.md

  tasks/
    task-schema.md
    feature-task.md
    bugfix-task.md
    refactor-task.md

  runtime/
    dispatcher.md
    task-router.md
    context-loader.md
    execution-loop.md
    escalation.md

scripts/
  lint-all.sh
  score.sh

  checks/
    arch/
    code/
    qa/

  policy/
    policy.yaml
```

---

## Task Model

### Task Schema

Every task must follow:

- id
- type (feature | bugfix | refactor)
- input
- output
- constraints
- acceptance_criteria
- affected_modules
- priority
- owner_role

### Principle

- Tasks must be verifiable
- No ambiguous outcomes
- Acceptance criteria must be testable

---

## Runtime

### Dispatcher

- Parses task
- Determines type
- Routes to role
- Starts execution loop

### Task Router

| Task Type | Role |
|----------|------|
| feature  | coder |
| bugfix   | coder |
| refactor | architect + coder |

---

### Context Loader

Load minimal sufficient context:

Always:
- arch/invariants.md
- task definition

Conditional:
- boundaries.md
- dev-conventions.md
- pitfalls.md

Never:
- full docs blindly

---

### Execution Loop

1. Read task
2. Load context
3. Execute
4. Run lint
5. Compute score

Decision:

- Score improves → continue
- Score drops → fix or rollback
- Blocked → escalate

Exit:

- Acceptance criteria met
- Score ≥ baseline

---

### Escalation

Trigger when:

- Cannot resolve constraints
- Conflicts exist
- Score stagnates

Actions:

- Ask human
- Record in known-issues.md
- Suggest invariant updates

---

## Policy Engine

### policy.yaml

Defines all enforceable constraints:

- architecture rules
- code standards
- QA requirements

Each policy has:

- name
- description
- check script
- weight

---

### Scoring

Quality score is computed from policy results:

Example:

- Architecture: 40%
- Tests: 30%
- Lint: 20%
- Docs: 10%

---

## Roles

Each role defines:

- Focus Areas
- Questions
- Working Standards

Roles:

- Product Manager
- Product Reviewer
- Architect
- Architecture Reviewer
- Coder
- Code Reviewer
- QA

---

## Workflow

1. Define task
2. Dispatch via runtime
3. Load context
4. Execute
5. Run lint + score
6. Iterate
7. Update knowledge base

---

## Interaction Rules

- Ask before assuming
- Extract, do not invent
- Blank is better than hallucination
- Always run lint after change
- Never bypass constraints

---

## Final Principle

> This is not a documentation system.  
> This is an execution system.

Agents do not follow instructions.  
Agents operate within systems.

Harness Engineering defines that system.

---

## Detailed Execution Specification

### Step 1: Project Understanding

Agent must:

1. Scan repository structure
2. Identify tech stack (language, framework)
3. Detect existing docs and constraints
4. Identify potential invariants (rules that must never break)

If unclear, ask:

- Who are the primary users (human / agent)?
- Known pitfalls?
- Required language for docs?
- Is this integrated with Claude Code / OpenClaw?

---

### Step 2: Navigation Setup

Create:

- AGENT.md → navigation only
- CLAUDE.md → pointer only (if applicable)

Rules:

- No business logic in AGENT.md
- Only links and entry points

---

### Step 3: Knowledge Extraction

Populate docs by extracting from codebase:

Sources:

- Code comments
- Git history
- Existing docs
- TODOs / FIXMEs

Rules:

- Do NOT invent
- Unknown → mark as `TODO: needs input`

---

### Step 4: Invariant Definition

Each invariant must include:

- Rule (non-negotiable)
- Reason
- Enforcement (script path)

Guideline:

- Focus on high-cost failures
- Focus on frequently broken patterns

---

### Step 5: Policy Binding

Every invariant SHOULD map to a policy check:

```
invariant → script → policy.yaml → score
```

If not enforceable:

- Mark as “manual invariant”
- Track in QA checklist

---

### Step 6: Task Execution Binding

Every task MUST:

- Map to a role
- Define acceptance criteria
- Be verifiable via score or tests

If not:

- Reject task as invalid

---

### Step 7: Continuous Evolution

After each execution:

1. New issue → add to pitfalls.md
2. Repeated issue → convert to invariant
3. New invariant → add policy check
4. Policy check → affects score

---

## Anti-Patterns (Strictly Forbidden)

- Writing large AGENT.md with full instructions
- Skipping lint checks
- Letting agent rely on conversation memory
- Creating docs not grounded in codebase
- Ignoring score regression
- Mixing roles without clear responsibility

---

## Maturity Levels

### Level 1: Documentation

- Only docs exist
- No enforcement

### Level 2: Structured Docs

- Navigation + layered docs
- Still manual

### Level 3: Harness (Current Target)

- Docs + lint + score
- Partial automation

### Level 4: Runtime System

- Task-driven execution
- Automated routing

### Level 5: Self-Evolving System

- Auto invariant extraction
- Auto policy generation

---

## Final Note

This system is designed to scale with:

- Project complexity
- Team size
- Number of agents

It should become:

- More strict over time (more constraints)
- More automated over time (less human routing)
- More reliable over time (fewer regressions)