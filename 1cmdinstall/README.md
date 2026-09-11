# 1cmdinstall — Company Operating System

Bootstrap a whole-company mono-repo that gives an AI coding agent full context to run
GTM, product, and ops for any business. Two prompts, run in order:

1. **`company-os-init.md`** — interviews you about your business (customers, operating
   model, assets, data sources, team) and scaffolds the repo: `customer/`, `product/`,
   `websites/`, `gtm/`, `decks/`, `cronjob/`, `context/{live,over_time,stable}/`, a dense
   root `CLAUDE.md`, and `.claude/{rules,skills}/`. Undecided answers become `# TODO:`
   markers instead of fabricated facts.
2. **`company-os-wire.md`** — run inside the scaffolded repo to add the machinery:
   git submodules for your product/website, an `AGENTS.md` mirror + sync script, a
   `Makefile` (`make sync` / `make ci`), pre-commit hooks, and a CI workflow.

## One-command install

Run in an empty repo, then paste the printed prompt into your coding agent:

```bash
curl -fsSL https://raw.githubusercontent.com/Miyamura80/code-agent-config/main/1cmdinstall/install.sh | sh
```

Or clone and copy the prompts in manually:

```bash
cp path/to/1cmdinstall/company-os-*.md .
```

Then open your coding agent (Claude Code, etc.) and paste `company-os-init.md`. After
the scaffold exists, paste `company-os-wire.md`.

## Design notes

- **Interview-driven**, not template-dumped: dirs are created only where your answers
  justify them.
- **`# TODO:` discipline**: every undecided decision stays an explicit open item; the
  agent never invents an answer. Both prompts end by listing all open TODOs.
- **Agent-first prose**: `CLAUDE.md` files are written dense, for an agent reader.
