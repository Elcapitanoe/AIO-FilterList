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
| **Active Filter Rules** | `1,029,630` |
| **Raw Rules Processed** | `1,241,217` |
| **Duplicates Removed** | `211,587` |
| **Sources Synced** | `18 upstream lists` |
| **Version Tag** | `26.09.12.0929` |
| **Last Synchronized** | `2026-09-12 09:29:00 UTC+7` |
<!-- AUTOGEN_STATS_END -->

---

## Upstream Sources & Standalone Mirrors

The routing table below lists all synchronized upstream lists with direct CDN mirror links and latest synchronization timestamps:

<!-- AUTOGEN_TABLE_START -->
| Filter Name | Upstream | Main Mirror | jsDelivr CDN | Edge CDN | Last Updated |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **1Hosts (Lite)** | [Source](https://badmojr.github.io/1Hosts/Lite/adblock.txt) | [hosts.domi](https://hosts.domi.my.id/filters/1hosts-lite.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/1hosts-lite.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/1hosts-lite.txt) | `2026-09-03 19:29:54` |
| **ABPindo** | [Source](https://raw.githubusercontent.com/ABPindo/indonesianadblockrules/master/subscriptions/abpindo.txt) | [hosts.domi](https://hosts.domi.my.id/filters/abpindo.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/abpindo.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/abpindo.txt) | `2026-09-11 19:21:21` |
| **AdGuard Annoyances** | [Source](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_14_Annoyances/filter.txt) | [hosts.domi](https://hosts.domi.my.id/filters/adguard-annoyances.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/adguard-annoyances.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/adguard-annoyances.txt) | `2026-09-11 19:21:21` |
| **AdGuard Base** | [Source](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt) | [hosts.domi](https://hosts.domi.my.id/filters/adguard-base.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/adguard-base.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/adguard-base.txt) | `2026-09-12 09:29:02` |
| **AdGuard Mobile ADS** | [Source](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_11_Mobile/filter.txt) | [hosts.domi](https://hosts.domi.my.id/filters/adguard-mobile-ads.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/adguard-mobile-ads.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/adguard-mobile-ads.txt) | `2026-09-11 19:21:21` |
| **AdGuard Protection** | [Source](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt) | [hosts.domi](https://hosts.domi.my.id/filters/adguard-tracking-protection.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/adguard-tracking-protection.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/adguard-tracking-protection.txt) | `2026-09-11 19:21:21` |
| **AdGuard Social Media** | [Source](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_4_Social/filter.txt) | [hosts.domi](https://hosts.domi.my.id/filters/adguard-social-media.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/adguard-social-media.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/adguard-social-media.txt) | `2026-09-11 19:21:21` |
| **AdGuard URL Tracking** | [Source](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_17_TrackParam/filter.txt) | [hosts.domi](https://hosts.domi.my.id/filters/adguard-url-tracking.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/adguard-url-tracking.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/adguard-url-tracking.txt) | `2026-09-11 19:21:21` |
| **EasyList** | [Source](https://easylist.to/easylist/easylist.txt) | [hosts.domi](https://hosts.domi.my.id/filters/easylist.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/easylist.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/easylist.txt) | `2026-09-12 09:29:02` |
| **EasyList Cookie List** | [Source](https://secure.fanboy.co.nz/fanboy-cookiemonster.txt) | [hosts.domi](https://hosts.domi.my.id/filters/fanboy-cookiemonster.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/fanboy-cookiemonster.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/fanboy-cookiemonster.txt) | `2026-09-12 09:29:02` |
| **Fanboy's Annoyance List** | [Source](https://secure.fanboy.co.nz/fanboy-annoyance.txt) | [hosts.domi](https://hosts.domi.my.id/filters/fanboy-annoyance.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/fanboy-annoyance.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/fanboy-annoyance.txt) | `2026-09-12 09:29:02` |
| **Fanboy's Social Blocking List** | [Source](https://easylist.to/easylist/fanboy-social.txt) | [hosts.domi](https://hosts.domi.my.id/filters/fanboy-social.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/fanboy-social.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/fanboy-social.txt) | `2026-09-12 09:29:02` |
| **HaGeZi's Pro** | [Source](https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/multi.txt) | [hosts.domi](https://hosts.domi.my.id/filters/hagezi-pro.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/hagezi-pro.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/hagezi-pro.txt) | `2026-09-11 19:21:21` |
| **OISD Big** | [Source](https://big.oisd.nl/domainswild) | [hosts.domi](https://hosts.domi.my.id/filters/oisd-big.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/oisd-big.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/oisd-big.txt) | `2026-09-12 09:29:02` |
| **Peter Lowe's List** | [Source](https://pgl.yoyo.org/adservers/serverlist.php?hostformat=adblockplus&showintro=1&mimetype=plaintext) | [hosts.domi](https://hosts.domi.my.id/filters/peter-lowes-list.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/peter-lowes-list.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/peter-lowes-list.txt) | `2026-09-11 19:21:21` |
| **ShadowWhisperer - ADS** | [Source](https://raw.githubusercontent.com/ShadowWhisperer/BlockLists/master/Lists/Ads) | [hosts.domi](https://hosts.domi.my.id/filters/shadowwhisperer-ads.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/shadowwhisperer-ads.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/shadowwhisperer-ads.txt) | `2026-09-12 09:29:02` |
| **Steven Black's Hosts** | [Source](https://raw.githubusercontent.com/StevenBlack/hosts/master/data/StevenBlack/hosts) | [hosts.domi](https://hosts.domi.my.id/filters/steven-blacks-hosts.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/steven-blacks-hosts.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/steven-blacks-hosts.txt) | `2026-08-07 17:39:23` |
| **URLhaus Malicious URL Blocklist** | [Source](https://malware-filter.gitlab.io/malware-filter/urlhaus-filter.txt) | [hosts.domi](https://hosts.domi.my.id/filters/urlhaus-malicious.txt) | [jsDelivr](https://cdn.jsdelivr.net/gh/Elcapitanoe/AIO-FilterList/filters/urlhaus-malicious.txt) | [cdn.domi](https://cdn.domi.my.id/Elcapitanoe/AIO-FilterList/filters/urlhaus-malicious.txt) | `2026-09-12 09:29:02` |
<!-- AUTOGEN_TABLE_END -->

---

## Pipeline Architecture

```
                                  [ config/sources.txt ]
                                             |
                                             v
[ Upstream Providers ]  -----( parallel fetch with staging )----->  [ filters/*.txt ]
                                                                           |
                                                                           v
                                                            [ scripts/merge_filters.sh ]
                                                            - Strip comments & headers
                                                            - Normalize CRLF
                                                            - Deduplicate (sort -u)
                                                                           |
                                             +-----------------------------+-----------------------------+
                                             |                                                           |
                                             v                                                           v
                                  [ AIO_Filter_List.txt ]                                         [ build.log ]
                                             |                                                           |
                                             +-----------------------------+-----------------------------+
                                                                           |
                                                                           v
                                                             [ scripts/update_readme.sh ]
                                                             - Inject build metrics
                                                             - Update mirror routing table
                                                                           |
                                                                           v
                                                                     [ README.md ]
```

1. **Ingestion & Mirroring (`scripts/fetch_filters.sh`)**: Concurrently fetches upstream sources using staged temporary files, verifying HTTP status and payload integrity before replacing local mirrors in `filters/`.
2. **Sanitization & Deduplication (`scripts/merge_filters.sh`)**: Streams filter files through a single `awk` pass to remove comments (`!`, `#`), empty lines, and section markers, then deduplicates via `LC_ALL=C sort -u`. Outputs the production artifact `AIO_Filter_List.txt` with Adblock metadata and generates `build.log`.
3. **Documentation Injection (`scripts/update_readme.sh`)**: Replaces dynamic blocks in `README.md` between HTML marker comments (`<!-- AUTOGEN_* -->`), keeping documentation clean without overwriting human-maintained content.
4. **Validation Suite (`scripts/validate.sh`)**: Verifies shell syntax, configuration schema, mirror presence, and compiled artifact integrity.

---

## Local Development & Setup

### Prerequisites

- Unix-like environment (Linux, macOS, or WSL)
- Bash `4.0+`
- GNU Coreutils (`awk`, `sort`, `wc`, `xargs`)
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
# Validate scripts, configuration, and artifacts
make validate
# or: ./scripts/validate.sh --check-artifacts

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
