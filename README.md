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
| ABPindo | [Original](https://raw.githubusercontent.com/ABPindo/indonesianadblockrules/master/subscriptions/abpindo.txt) | [Mirror](https://hosts.domi.my.id/filters/abpindo.txt) | 2026-05-05 00:30:16 |
| AdGuard Annoyances | [Original](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_14_Annoyances/filter.txt) | [Mirror](https://hosts.domi.my.id/filters/adguard-annoyances.txt) | 2026-05-05 00:30:16 |
| AdGuard Base | [Original](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt) | [Mirror](https://hosts.domi.my.id/filters/adguard-base.txt) | 2026-05-05 00:30:16 |
| AdGuard Mobile ADS | [Original](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_11_Mobile/filter.txt) | [Mirror](https://hosts.domi.my.id/filters/adguard-mobile-ads.txt) | 2026-05-05 00:30:16 |
| AdGuard Protection | [Original](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt) | [Mirror](https://hosts.domi.my.id/filters/adguard-tracking-protection.txt) | 2026-05-05 00:30:16 |
| AdGuard Social Media | [Original](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_4_Social/filter.txt) | [Mirror](https://hosts.domi.my.id/filters/adguard-social-media.txt) | 2026-05-05 00:30:16 |
| AdGuard URL Tracking | [Original](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_17_TrackParam/filter.txt) | [Mirror](https://hosts.domi.my.id/filters/adguard-url-tracking.txt) | 2026-05-04 04:19:20 |
| EasyList | [Original](https://easylist.to/easylist/easylist.txt) | [Mirror](https://hosts.domi.my.id/filters/easylist.txt) | 2026-05-05 00:30:16 |
| EasyList Cookie List | [Original](https://secure.fanboy.co.nz/fanboy-cookiemonster.txt) | [Mirror](https://hosts.domi.my.id/filters/fanboy-cookiemonster.txt) | 2026-05-04 04:19:20 |
| Fanboy's Annoyance List | [Original](https://secure.fanboy.co.nz/fanboy-annoyance.txt) | [Mirror](https://hosts.domi.my.id/filters/fanboy-annoyance.txt) | 2026-05-04 04:19:20 |
| Fanboy's Social Blocking List | [Original](https://easylist.to/easylist/fanboy-social.txt) | [Mirror](https://hosts.domi.my.id/filters/fanboy-social.txt) | 2026-05-05 00:30:16 |
| HaGeZi's Pro | [Original](https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/multi.txt) | [Mirror](https://hosts.domi.my.id/filters/hagezi-pro.txt) | 2026-05-05 00:30:16 |
| OISD Big | [Original](https://big.oisd.nl/domainswild) | [Mirror](https://hosts.domi.my.id/filters/oisd-big.txt) | 2026-05-05 00:30:16 |
| URLhaus Malicious URL Blocklist | [Original](https://malware-filter.gitlab.io/malware-filter/urlhaus-filter.txt) | [Mirror](https://hosts.domi.my.id/filters/urlhaus-malicious.txt) | 2026-05-05 00:30:16 |

### How It Works

A GitHub Action runs automatically every day to pull the latest raw text files from the URLs listed above. The script strips out the original metadata headers to prevent parsing errors, removes duplicate rules to keep the file lightweight, and compiles everything into the `AIO_Filter_List.txt` file located in the root directory.
