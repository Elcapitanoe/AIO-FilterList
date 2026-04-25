<br />
<h1 align="center">AIO Filter List</h1>
<br />
Before you dive in, I want to make it absolutely clear that I do not claim ownership or take any credit for the filter rules found in this repository. I did not write them, and I do not maintain the original blocklists.

This project is simply an automated aggregation tool. It routinely fetches, cleans, and merges several highly respected community filter lists into a single file for my own convenience, and I am making it public in case others find it useful.

All credit belongs entirely to the original authors and the communities that spend their time keeping these web filters updated. If you appreciate the ad-blocking and privacy protection provided here, please support the upstream maintainers.

### Direct Access
```
https://hosts.domi.my.id/AIO_Filter_List.txt
```

### Upstream Sources

This repository is built on the hard work of the following projects. Here is the exact list of sources pulled during the automation process:

| Filter Name | Original Source | Mirror Link | Last Updated |
|---|:---:|:---:|:---:|
| 1Hosts (Lite) | [Original](https://raw.githubusercontent.com/badmojr/1Hosts/master/Lite/hosts.txt) | [Mirror](https://hosts.domi.my.id/filters/1host-lite.txt) | 2026-04-24 09:27:39 UTC+7 |
| 1Hosts (Xtra) | [Original](https://raw.githubusercontent.com/badmojr/1Hosts/refs/heads/master/Xtra/adblock.txt) | [Mirror](https://hosts.domi.my.id/filters/1host-xtra.txt) | 2026-04-24 09:27:39 UTC+7 |
| ABPindo | [Original](https://raw.githubusercontent.com/ABPindo/indonesianadblockrules/master/subscriptions/abpindo.txt) | [Mirror](https://hosts.domi.my.id/filters/abpindo.txt) | 2026-04-24 09:52:19 UTC+7 |
| AdGuard Annoyances Filter | [Original](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_14_Annoyances/filter.txt) | [Mirror](https://hosts.domi.my.id/filters/adguard-annoyances.txt) | 2026-04-25 00:40:43 UTC+7 |
| AdGuard Base Filter | [Original](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt) | [Mirror](https://hosts.domi.my.id/filters/adguard-base.txt) | 2026-04-25 01:09:47 UTC+7 |
| AdGuard Tracking Protection | [Original](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt) | [Mirror](https://hosts.domi.my.id/filters/adguard-tracking.txt) | 2026-04-25 01:09:47 UTC+7 |
| AdGuard URL Tracking Filter | [Original](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_17_TrackParam/filter.txt) | [Mirror](https://hosts.domi.my.id/filters/adguard-tracking-url.txt) | 2026-04-23 12:19:02 UTC+7 |
| Dan Pollock's Hosts File | [Original](https://someonewhocares.org/hosts/hosts) | [Mirror](https://hosts.domi.my.id/filters/dan-pollock-host.txt) | 2026-04-25 00:40:43 UTC+7 |
| EasyList | [Original](https://easylist.to/easylist/easylist.txt) | [Mirror](https://hosts.domi.my.id/filters/easylist.txt) | 2026-04-25 08:19:36 UTC+7 |
| EasyPrivacy | [Original](https://easylist.to/easylist/easyprivacy.txt) | [Mirror](https://hosts.domi.my.id/filters/easyprivacy.txt) | 2026-04-25 08:19:36 UTC+7 |
| Fanboy's Annoyance List | [Original](https://secure.fanboy.co.nz/fanboy-annoyance.txt) | [Mirror](https://hosts.domi.my.id/filters/fanboy-annoyance.txt) | 2026-04-25 01:09:47 UTC+7 |
| Fanboy's Cookie Monster List | [Original](https://secure.fanboy.co.nz/fanboy-cookiemonster.txt) | [Mirror](https://hosts.domi.my.id/filters/fanboy-cookiemonster.txt) | 2026-04-25 01:09:47 UTC+7 |
| Fanboy's Social Blocking List | [Original](https://easylist.to/easylist/fanboy-social.txt) | [Mirror](https://hosts.domi.my.id/filters/fanboy-social.txt) | 2026-04-25 08:19:36 UTC+7 |
| HaGeZi's Pro | [Original](https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/multi.txt) | [Mirror](https://hosts.domi.my.id/filters/hagezi-pro.txt) | 2026-04-25 00:40:43 UTC+7 |
| OISD Big | [Original](https://big.oisd.nl/domainswild) | [Mirror](https://hosts.domi.my.id/filters/oisd-big.txt) | 2026-04-25 01:09:47 UTC+7 |
| Peter Lowe's Ad and Tracking Server List | [Original](https://pgl.yoyo.org/adservers/serverlist.php?hostformat=adblockplus&showintro=1&mimetype=plaintext) | [Mirror](https://hosts.domi.my.id/filters/peter-lowes-ad-tracking-server.txt) | 2026-04-24 12:37:28 UTC+7 |
| Spam404 Blocklist | [Original](https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt) | [Mirror](https://hosts.domi.my.id/filters/spam404-blocklist.txt) | 2026-04-24 01:05:46 UTC+7 |
| Steven Black's Hosts | [Original](https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts) | [Mirror](https://hosts.domi.my.id/filters/steven-black-host.txt) | 2026-04-24 00:44:57 UTC+7 |
| URLhaus Malicious URL Blocklist | [Original](https://malware-filter.gitlab.io/malware-filter/urlhaus-filter.txt) | [Mirror](https://hosts.domi.my.id/filters/urlhaus-malicious.txt) | 2026-04-25 00:40:43 UTC+7 |

### How It Works

A GitHub Action runs automatically every day to pull the latest raw text files from the URLs listed above. The script strips out the original metadata headers to prevent parsing errors, removes duplicate rules to keep the file lightweight, and compiles everything into the `AIO_Filter_List.txt` file located in the root directory.
