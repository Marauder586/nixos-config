# Coding skill

## Toolbelt installed in this environment

| Need                    | Tool                                |
| ----------------------- | ----------------------------------- |
| File search             | `rg` (ripgrep), `fd`                |
| JSON / YAML / XML       | `jq`, `yq`, `dasel`, `xmlstarlet`   |
| HTTP                    | `xh`, `httpie`, `curl`              |
| GitHub                  | `gh`                                |
| Diff viewer             | `delta` (already wired into git)    |
| Bench                   | `hyperfine`                         |
| LOC / inventory         | `tokei`                             |
| Markdown render         | `glow`                              |
| Format converter        | `pandoc`                            |
| Task runner             | `just`                              |

## Per-language hygiene

- **Python:** prefer `uv` for envs (`uv venv`, `uv pip install`); lint with
  `ruff check`, format with `ruff format`, type with `mypy --strict`.
  Test with `pytest` or `unittest`.
- **JS/TS:** prefer `pnpm`. Format with `prettier`. Lint with `eslint` if
  configured. Type with `tsc --noEmit`.
- **Go:** `go vet`, `go test ./...`, `gofmt -s -w .`.
- **Rust:** `cargo clippy --all-targets`, `cargo test`, `cargo fmt`.
- **Nix:** `alejandra .` to format, `nix flake check` to validate, build a
  single host with `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.
- **Shell:** `shellcheck`, `shfmt -i 2 -w`.

## Git etiquette

- Read `git status` and `git diff` before touching anything.
- Commit only when asked. Match the repo's existing message style.
- Never use `--no-verify` to skip hooks unless explicitly told.
- Never `git push --force` to a shared branch.

## Editing rules

- Read the file before editing it.
- Smallest diff that fixes the problem; don't drag in tangential cleanup.
- Match surrounding style (indent width, quote flavour, naming).
- Avoid commentary that explains *what* the code does — the code says that.
  Comments only for *why* (constraints, gotchas, links to issues).
