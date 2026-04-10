# Architecture Documentation

This directory contains generated architecture documents produced by the BDAT (Business–Data–Application–Technology) framework prompts.

## Documents

| File           | Layer    | Generator Prompt                                       | Description                                    |
|----------------|----------|--------------------------------------------------------|------------------------------------------------|
| `bu-arch.md`   | Business | `.github/prompts/bu-arch-generator.prompt.md`          | Business Architecture — TOGAF 10 ADM Phase B   |

## Generating Documents

Architecture documents are generated using the prompt files in `.github/prompts/`. Open the relevant prompt file in GitHub Copilot Chat or Claude Code and follow the instructions to produce or refresh a document.

### Business Architecture

```
Prompt: .github/prompts/bu-arch-generator.prompt.md
Output: docs/architecture/bu-arch.md
```

> **Note:** Generated documents reflect the state of the codebase at generation time. Re-run the prompt when significant architectural changes are made to keep documentation current.
