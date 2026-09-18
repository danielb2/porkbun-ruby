# Porkbun Ruby Agent Guide

This repository contains a Ruby gem and CLI for the Porkbun API. The project is a partial implementation focused on the author's needs.

## Rules

- Read the relevant Ruby source and tests before changing behavior.
- Implement behavior in the local library API (`lib/`), not in the CLI. Keep CLI commands as thin argument and output adapters.
- Keep changes focused. Do not add speculative features or refactors.
- Add or update RSpec coverage for behavior changes.
- Run the test suite after every code modification and before every commit. Report the result.
- Update `README.md` every time you change code. Keep it in sync with the current API, CLI, and usage after every code modification; do not defer documentation updates. Update `CHANGELOG.md` with every user-facing change.
- Before bumping any dependency or project version, actually check the current latest release in an authoritative package registry. Do not rely on memory, an old lockfile, or an assumed version.
- Treat API and CLI renames as breaking changes. Update the major version when they remove or rename public behavior.
- Absolutely never commit, push, or change shared Git state unless the user explicitly instructs you to do so.

## Structure

- `lib/` — gem implementation.
- `bin/` — executable scripts, including the CLI.
- `spec/` — RSpec tests.
- `README.md` — usage, API, CLI, and development documentation.
- `.github/workflows/` — CI configuration.

## Commands

- Install dependencies: `bin/setup`
- Run tests: `bundle exec rake` or `bundle exec rspec`
- Open a console: `bin/console`
- Install the gem locally: `bundle exec rake install`
- Release the gem: `bundle exec rake release`

## Documentation routing

| Topic | Document |
| --- | --- |
| Usage, API, CLI, development, and contributing | [README.md](README.md) |

## Documentation and changelog

Update the relevant documentation and `CHANGELOG.md` with each user-facing change. Keep entries short and factual. If a change needs a design note, explain the decision and its impact in the relevant documentation.
