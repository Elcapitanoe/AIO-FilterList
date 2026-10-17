# AIO Filter List

[![Upstream Filter Synchronization](https://github.com/Elcapitanoe/AIO-FilterList/actions/workflows/sync-filters.yml/badge.svg)](https://github.com/Elcapitanoe/AIO-FilterList/actions/workflows/sync-filters.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An automated aggregation pipeline and CDN mirror network for community adblock filter lists. This repository synchronizes upstream filter subscriptions daily, provides standalone high-availability mirrors, deduplicates rules into a unified consolidated list, and automatically publishes build telemetry.

---

## Direct Subscription URLs

Subscribe to the consolidated `AIO_Filter_List.txt` in any compatible adblocker (uBlock Origin, AdGuard, Brave, Vivaldi, Pi-hole, AdGuard Home):

| Provider | Endpoint URL |
| :--- | :--- |
| **Primary Domain** | `https://hosts.domi.my.id/AIO_Filter_List.txt` |
| **jsDelivr CDN** | `https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/AIO_Filter_List.txt` |
| **Edge CDN** | `https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/AIO_Filter_List.txt` |

---

## Build Telemetry

<!-- AUTOGEN_STATS_START -->
| Metric | Value |
| :--- | :--- |
| **Active Filter Rules** | `2,873,562` |
| **Raw Rules Processed** | `3,167,540` |
| **Duplicates Removed** | `293,978` |
| **Sources Synced** | `8 upstream lists` |
| **Version Tag** | `26.10.18.0156` |
| **Last Synchronized** | `2026-10-18 01:56:21 UTC+7` |
<!-- AUTOGEN_STATS_END -->

---

## Upstream Sources & Standalone Mirrors

The routing table below lists all synchronized upstream lists with direct CDN mirror links. Timestamps come from Git history; they are shown as `unknown` when the repository is run from an archive without Git metadata.

<!-- AUTOGEN_TABLE_START -->
| Filter Name | Upstream | Main Mirror | jsDelivr CDN | Edge CDN | Last Updated |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **HaGeZi's Anti Piracy** | [Source](https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/anti.piracy.txt) | [hosts.domi](https://hosts.domi.my.id/filters/hagezi-anti-piracy.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/hagezi-anti-piracy.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/hagezi-anti-piracy.txt) | `2026-10-18 01:56:21` |
| **HaGeZi's DoH/VPN/Tor/Proxy Bypass** | [Source](https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/doh-vpn-proxy-bypass.txt) | [hosts.domi](https://hosts.domi.my.id/filters/hagezi-doh-vpn-proxy-bypass.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/hagezi-doh-vpn-proxy-bypass.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/hagezi-doh-vpn-proxy-bypass.txt) | `2026-10-18 01:56:21` |
| **HaGeZi's Gambling** | [Source](https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/gambling.txt) | [hosts.domi](https://hosts.domi.my.id/filters/hagezi-gambling.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/hagezi-gambling.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/hagezi-gambling.txt) | `2026-10-18 01:56:22` |
| **HaGeZi's Multi Pro** | [Source](https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt) | [hosts.domi](https://hosts.domi.my.id/filters/hagezi-pro.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/hagezi-pro.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/hagezi-pro.txt) | `2026-10-18 01:56:22` |
| **HaGeZi's NSFW** | [Source](https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/nsfw.txt) | [hosts.domi](https://hosts.domi.my.id/filters/hagezi-nsfw.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/hagezi-nsfw.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/hagezi-nsfw.txt) | `2026-10-18 01:56:22` |
| **HaGeZi's Pop-Up Ads** | [Source](https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/popupads.txt) | [hosts.domi](https://hosts.domi.my.id/filters/hagezi-popupads.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/hagezi-popupads.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/hagezi-popupads.txt) | `2026-10-18 01:56:22` |
| **HaGeZi's Threat Intelligence Feeds** | [Source](https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/tif.txt) | [hosts.domi](https://hosts.domi.my.id/filters/hagezi-tif.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/hagezi-tif.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/hagezi-tif.txt) | `2026-10-18 01:56:22` |
| **ShadowWhisperer's Tracking** | [Source](https://cdn.jsdelivr.net/gh/ShadowWhisperer/BlockLists@latest/Lists/Tracking) | [hosts.domi](https://hosts.domi.my.id/filters/shadowwhisperer-tracking.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/shadowwhisperer-tracking.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/shadowwhisperer-tracking.txt) | `2026-10-18 01:56:22` |
<!-- AUTOGEN_TABLE_END -->

---

## Pipeline Architecture

1. **Ingestion & Mirroring (`scripts/fetch_filters.sh`)**: Fetches upstream sources with bounded concurrency into a staging directory. It rejects empty or obviously invalid responses, applies new mirrors only after every configured download succeeds, and avoids replacing files whose contents are unchanged. Stale mirrors are removed only after a successful full sync.
2. **Sanitization & Deduplication (`scripts/merge_filters.sh`)**: Processes only sources declared in `config/sources.txt`, normalizes surrounding whitespace and line endings, removes comments and section markers, and deduplicates via `LC_ALL=C sort -u`. An input signature and output checksum allow no-op runs to skip the expensive merge and avoid rewriting the large published list when only upstream metadata changes.
3. **Documentation Injection (`scripts/update_readme.sh`)**: Replaces dynamic blocks in `README.md` between HTML marker comments (`<!-- AUTOGEN_* -->`), keeping documentation clean without overwriting human-maintained content.
4. **Validation Suite (`scripts/validate.sh`)**: Verifies shell syntax, configuration schema, mirror presence, and compiled artifact integrity.

---

## Local Development & Setup

### Prerequisites

- Unix-like environment (Linux, macOS, or WSL)
- Bash `4.0+`
- Core utilities (`awk`, `sort`, `wc`, `xargs`) and either `sha256sum` or `shasum`
- `curl`
- `git`
- `make` (optional, for convenience)

### Quickstart

Clone the repository:

```bash
git clone https://github.com/Elcapitanoe/AIO-FilterList.git
cd AIO-FilterList
```

Run pipeline targets:

```bash
# Validate scripts, configuration, and project metadata
make validate
# Run offline regression tests
make test
# Validate generated artifacts after a build
./scripts/validate.sh --check-artifacts

# Fetch upstream filter lists into filters/
make fetch
# or: ./scripts/fetch_filters.sh

# Compile and deduplicate into AIO_Filter_List.txt
make merge
# or: ./scripts/merge_filters.sh

# Update README.md telemetry and table markers
make readme
# or: ./scripts/update_readme.sh

# Execute full pipeline end-to-end
make all
```

---

## Adding Upstream Sources

To register a new upstream list, append an entry to `config/sources.txt` in pipe-delimited format:

```text
filename.txt|https://upstream.example.com/filter.txt|Display Name
```

Rules:
- Filename must end in `.txt` and be unique within `config/sources.txt`.
- URL must be a valid HTTP or HTTPS endpoint returning plain text filter rules.
- Run `make validate` to ensure configuration syntax before committing.

---

## Disclaimer & Attribution

**The maintainer of this repository does not claim ownership or authorship of the upstream filter rules.** This project is strictly an automated aggregation, deduplication, and high-availability mirror utility. All credit and copyright belong to the respective upstream maintainers and open-source communities. Please support the upstream projects listed in the routing table.

---

## License

This pipeline code and configuration are licensed under the [MIT License](LICENSE). Aggregated upstream filter lists remain subject to their respective original licenses and terms.
