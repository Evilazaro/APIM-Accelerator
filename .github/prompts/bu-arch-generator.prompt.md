---
title: "Business Architecture Generator"
version: "1.1.0"
updated: "2026-04-10"
status: "production"
collection: "bdat-orchestration"
role: "layer-generator"
compliance: "promptgen-v2.0"
priority: 1
estimated_read_time: "5 min"
dependencies:
  - name: "orchestrated/coordinator.prompt.md"
    type: "required"
---

#file:./orchestrated/coordinator.prompt.md

# Business Architecture Generator

## 📋 Quick Reference

**TL;DR:** Load `/coordinator` → Analyze workspace → Generate Business Architecture document → Validate against all mandatory gates → Write to `./docs/architecture/bu-arch.md`

**Key Constraints:** Comprehensive quality level | Sections [1, 2, 3, 4, 5, 7, 8] | Exclude `.claude/` directory | All gates must pass at 100/100

**Dependency:** `/coordinator` prompt and all its declared sub-dependencies

---

## 📥 Dependencies (Load Before Starting)

> **BLOCKING** — load and read each dependency in full before producing any output:

| #   | File                    | Load Command                                 | Purpose                                                                       |
| --- | ----------------------- | -------------------------------------------- | ----------------------------------------------------------------------------- |
| 1   | `coordinator.prompt.md` | `#file:./orchestrated/coordinator.prompt.md` | Orchestration workflow, section schema, mandatory gates, and sub-dependencies |

---

## 🎭 Role

You are a **Business Architecture Generator** within the BDAT framework. Load and execute the `/coordinator` orchestration workflow to produce a comprehensive Business Architecture document through full workspace analysis.

---

## 🎯 Goal

Comprehensively **analyze** the workspace and **generate** a Business Architecture document by executing the `/coordinator` orchestration workflow with the parameters defined in the Inputs section.

---

## 🌐 Context

- **Environment:** Claude Code / GitHub Copilot Chat in VS Code
- **Framework:** TOGAF 10 Architecture Development Method (ADM)
- **Scope:** Full workspace analysis for the Business architecture layer
- **Quality Bar:** Comprehensive — all mandatory gates must pass at 100/100

---

## 📋 Instructions

> **Reasoning Approach:** Apply Chain-of-Thought reasoning — before executing each step, reason about the inputs available, the analysis required, and the expected output for that step.

1. **Load** the `/coordinator` prompt and all its declared dependencies **before** producing any output. If any dependency fails to load, halt and report the missing dependency (see Error Handling).
2. **Read all instructions** in the `/coordinator` prompt and every loaded dependency **before** producing any output.
3. **Analyze** the entire workspace (excluding `.claude/` directory):
   - Scan source files (e.g., `.ts`, `.js`, `.py`, `.cs`, `.java`), configuration files (e.g., `package.json`, `*.config`, `*.yaml`), and documentation (e.g., `*.md`, `README`).
   - Identify business processes, capabilities, services, and organizational functions by examining entry points, service definitions, API routes, and domain models.
   - Map stakeholder interactions, value streams, and business rules by analyzing workflows, event handlers, and business logic modules.
   - Catalog business services, contracts, and integration points by examining API schemas, service interfaces, and external dependency configurations.
4. **Generate** a Business Architecture document containing the sections defined in the `/coordinator` prompt for `output_sections` [1, 2, 3, 4, 5, 7, 8], ensuring each section is complete and accurately reflects the implementation, features, and use cases discovered during analysis.
5. **Validate** the output against all mandatory gates defined in `/coordinator` and its dependencies. Each gate must score 100/100 before proceeding.
6. **Write** the final Business Architecture document to the path specified in `output_path`.
7. **Report** any issues, gaps, or missing information using the format defined in the Output Schema section.
8. **Iterate** on the output based on feedback and validation results (maximum 3 retry attempts per gate). If all gates do not pass after 3 attempts, halt and report the blocking gate ID and failure reason.

---

## 📥 Inputs

| Parameter         | Value                              | Description                                                                                                               |
| ----------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `target_layers`   | `["Business"]`                     | BDAT layer to generate architecture for                                                                                   |
| `quality_level`   | `"comprehensive"`                  | All mandatory gates must pass at 100/100                                                                                  |
| `folder_paths`    | `["."]`                            | Root workspace directory to analyze                                                                                       |
| `output_path`     | `"./docs/architecture/bu-arch.md"` | File path for the generated document                                                                                      |
| `output_sections` | `[1, 2, 3, 4, 5, 7, 8]`            | Section numbers as defined in `/coordinator`'s section schema (section 6 excluded — not applicable to the Business layer) |

---

## 🔒 Constraints

### Negative Constraints

- **Do not** produce any output until all instructions have been read and understood.
- **Do not** generate the Business Architecture document until the entire workspace has been analyzed.
- **Do not** skip any sections defined in the `output_sections` input.
- **Do not** ignore any mandatory gates defined in the `/coordinator` prompt or its dependencies.
- **Do not** produce an incomplete or inaccurate Business Architecture document.
- **Do not** proceed to the next step until all issues, gaps, or missing information have been reported and addressed.
- **Do not** finalize the document until all feedback and validation results have been incorporated.
- **Do not** analyze the `./.claude` directory or any of its contents.
- **Do not** produce any output that is not directly related to the generation of the Business Architecture document.
- **Do not** fabricate, hallucinate, or invent content not directly supported by the analyzed workspace artifacts.

### Positive Constraints

- **Ensure** the Business Architecture document is comprehensive, well-structured, and accurately reflects the implementation, features, and use cases present in the codebase.
- **Ensure** the workspace analysis is thorough, covering all source files, configurations, and documentation needed for an accurate Business Architecture document.
- **Ensure** all mandatory gates from `/coordinator` and its dependencies pass at 100/100 before finalizing the document.
- **Ensure** all feedback, validation results, issues, gaps, and missing information are incorporated and reported using the Output Schema format.
- **Ensure** all instructions in the `/coordinator` prompt and its dependencies are followed precisely.
- **Ensure** the final document meets the `quality_level` of "comprehensive", includes all specified `output_sections`, and is saved to the specified `output_path`.

---

## ⚠️ Error Handling

| Scenario                           | Error Code | Action                                                                            |
| ---------------------------------- | ---------- | --------------------------------------------------------------------------------- |
| `/coordinator` fails to load       | ERR-001    | Halt execution; report the missing dependency and its file path                   |
| A sub-dependency fails to load     | ERR-002    | Halt execution; report the missing sub-dependency with its expected path          |
| Workspace contains no source files | ERR-003    | Halt execution; report that no analyzable source files were found in folder_paths |
| A mandatory gate fails after retry | ERR-004    | Halt after 3 attempts; report the gate ID, score, and failure reason              |
| Output path is not writable        | ERR-005    | Halt execution; report the path and permission issue                              |

---

## 🔀 Edge Cases

| Scenario                                                                 | Action                                                                                                         |
| ------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------- |
| Workspace contains only configuration files (no application source code) | Generate architecture based on available configuration; report limited source coverage in Issues & Gaps        |
| Multiple programming languages or frameworks detected                    | Document all detected technologies; organize findings by component or module                                   |
| No explicit business logic found (e.g., utility or library codebase)     | Document the codebase as infrastructure-focused; report absence of business process artifacts in Issues & Gaps |
| Workspace exceeds 10,000 files                                           | Prioritize entry points, configuration files, and public APIs; note sampling strategy in Issues & Gaps         |

---

## 🔄 Fallback Behavior

If unable to complete the full analysis:

1. State the specific blocker and reference the relevant error code (ERR-001 through ERR-005).
2. Produce a partial document covering all sections that could be completed.
3. Mark incomplete sections with `<!-- INCOMPLETE: [reason] -->` in the output file.
4. Report all incomplete sections in the Issues & Gaps table with status `Open`.
5. Do **NOT** fabricate content for sections that could not be analyzed.

---

## ✅ Validation (Self-Check Before Output)

Before finalizing, verify **all** of the following:

- [ ] `/coordinator` prompt and all dependencies loaded successfully — ERR-001, ERR-002
- [ ] Entire workspace analyzed (excluding `./.claude` directory) — ERR-003
- [ ] All sections in `output_sections` [1, 2, 3, 4, 5, 7, 8] generated
- [ ] All mandatory gates from `/coordinator` pass at 100/100 — ERR-004
- [ ] Document written to `./docs/architecture/bu-arch.md` — ERR-005
- [ ] No fabricated or hallucinated content in the document
- [ ] Zero `TODO`, `TBD`, `PLACEHOLDER`, or `Coming soon` text in output

> **If any check fails:** Report the failing check, iterate (max 3 attempts), and re-validate. If still failing after 3 attempts, halt and report the blocking issue with its error code.

---

## 📊 Success Metrics

| Metric             | Target            | Measurement                                                       |
| ------------------ | ----------------- | ----------------------------------------------------------------- |
| Dependency Loading | 100%              | All dependencies loaded successfully (ERR-001, ERR-002)           |
| Workspace Coverage | 100%              | All source, config, and doc files analyzed (excluding `.claude/`) |
| Section Completion | 7/7               | All `output_sections` [1, 2, 3, 4, 5, 7, 8] generated             |
| Gate Pass Rate     | 100%              | All mandatory gates from `/coordinator` pass at 100/100           |
| Content Integrity  | 0% fabrication    | No hallucinated or invented content in output                     |
| Output Cleanliness | Zero placeholders | No `TODO`, `TBD`, `PLACEHOLDER`, or `Coming soon` text            |

---

## 📤 Output Schema

### 1. Business Architecture Document

Written to `./docs/architecture/bu-arch.md` in Markdown format, containing all sections from `output_sections` [1, 2, 3, 4, 5, 7, 8] as defined by the `/coordinator`'s section schema. Must accurately reflect the implementation, features, and use cases present in the codebase.

### 2. Issues & Gaps Report

**Valid Categories:** `gap` (missing information), `issue` (incorrect or inconsistent content), `limitation` (cannot be resolved from available source), `assumption` (inference made due to ambiguous source)

**Valid Statuses:** `Resolved`, `Open`, `Deferred`

```markdown
## Issues & Gaps

| #   | Category   | Description                                      | Resolution                         | Status   |
| --- | ---------- | ------------------------------------------------ | ---------------------------------- | -------- |
| 1   | gap        | No API versioning strategy found in source files | Documented as architectural gap    | Open     |
| 2   | assumption | Database type inferred from ORM configuration    | Noted inference basis in Section 4 | Resolved |
```

### 3. Validation Summary

```markdown
## Validation Summary

| Gate ID | Gate Name               | Score   | Status |
| ------- | ----------------------- | ------- | ------ |
| [ID]    | [name from coordinator] | 100/100 | Pass   |
```
