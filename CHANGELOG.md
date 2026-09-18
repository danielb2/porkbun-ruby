# Changelog

All notable changes to this project are documented here.

## [2.0.0] - 2026-09-18

- Removed the CLI `list` and `retrieve` commands and replaced them with the single `ls` command for listing domains or retrieving records for a domain and optional record ID.
- Renamed the CLI `create` command to `add` and `delete_all` to `rm_rf`.
- Added the `rm` CLI command for deleting one unambiguous record by hostname, with or without a trailing dot.
- Added the `update` CLI command, with `up` as an alias, to change record content or TTL.
- Replaced the public `Porkbun::DNS.retrieve` API with `Porkbun::Domain.list`.
- Added `Porkbun.new(domain)` domain objects and `Porkbun::Record` objects for record retrieval, creation, update, and deletion.
- Added `Porkbun::Domain#zone_file`, `Porkbun::Domain.import`, and explicit `get_record` naming.
- Added RSpec coverage for `Porkbun::Domain.list`.
- Updated Thor to `1.5.0`.
- Fixed `--help` handling for CLI commands.
- Added project guidance in `AGENTS.md` and `CLAUDE.md`.
- Removed the external `http` dependency in favor of Ruby's standard library.
- Raised the minimum supported Ruby version to `3.2.0`.
- Updated development dependencies to their latest compatible releases.
