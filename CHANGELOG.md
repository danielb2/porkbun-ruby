# Changelog

All notable changes to this project are documented here.

## [2.0.0] - 2026-09-18

- Added the `ls` CLI command for listing domains or retrieving records for a domain and optional record ID.
- Renamed the CLI `create` command to `add` and `delete_all` to `rm_rf`.
- Removed the `retrieve` CLI command.
- Replaced the public `Porkbun::DNS.retrieve` API with `Porkbun::DNS.list`.
- Added RSpec coverage for `Porkbun::DNS.list`.
- Updated Thor to `1.5.0`.
- Fixed `--help` handling for CLI commands.
- Added project guidance in `AGENTS.md` and `CLAUDE.md`.
- Removed the external `http` dependency in favor of Ruby's standard library.
- Raised the minimum supported Ruby version to `3.2.0`.
- Updated development dependencies to their latest compatible releases.
