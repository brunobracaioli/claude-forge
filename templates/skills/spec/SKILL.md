---
name: spec
description: Interview the user about a feature, then write a detailed spec to SPEC.md.
argument-hint: "[feature-description]"
disable-model-invocation: true
allowed-tools: Read, Write, Edit
---

I want to build: $ARGUMENTS

Interview me in detail using the AskUserQuestion tool (or direct questions if unavailable).

Ask about:
- **Functional requirements**: what exactly should this do? What inputs/outputs?
- **Edge cases**: what happens when things go wrong? Empty inputs? Concurrent access?
- **UI/UX** (if applicable): what does the user see? What's the interaction flow?
- **Data model**: what entities, relationships, constraints?
- **Integration points**: what external services, APIs, or existing code is involved?
- **Non-functional**: performance targets, security requirements, compliance?
- **Tradeoffs**: what's the MVP vs. the ideal? What can we cut?

Don't ask obvious questions. Dig into the hard parts I might not have considered.

Keep interviewing until we've covered everything, then write a complete spec to `SPEC.md` with:

1. Overview
2. Requirements (functional + non-functional)
3. Technical design
4. Data model
5. API contracts (if applicable)
6. Edge cases and error handling
7. Test plan
8. Open questions

After the spec is written, suggest: "Start a fresh session to implement from SPEC.md"
