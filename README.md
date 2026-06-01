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

| Filter Name | Primary | Mirror | Updated At |
|:---|:---:|:---:|:---:|
| 1Hosts (Lite) | [Main URL](https://badmojr.github.io/1Hosts/Lite/adblock.txt) | [Mirror URL](https://hosts.domi.my.id/filters/1hosts-lite.txt) | 2026-06-02, 01:53:08 |
| ABPindo | [Main URL](https://raw.githubusercontent.com/ABPindo/indonesianadblockrules/master/subscriptions/abpindo.txt) | [Mirror URL](https://hosts.domi.my.id/filters/abpindo.txt) | 2026-05-31, 17:22:32 |
| AdGuard Annoyances | [Main URL](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_14_Annoyances/filter.txt) | [Mirror URL](https://hosts.domi.my.id/filters/adguard-annoyances.txt) | 2026-06-02, 01:53:08 |
| AdGuard Base | [Main URL](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt) | [Mirror URL](https://hosts.domi.my.id/filters/adguard-base.txt) | 2026-06-02, 01:53:08 |
| AdGuard Mobile ADS | [Main URL](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_11_Mobile/filter.txt) | [Mirror URL](https://hosts.domi.my.id/filters/adguard-mobile-ads.txt) | 2026-06-02, 01:53:08 |
| AdGuard Protection | [Main URL](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt) | [Mirror URL](https://hosts.domi.my.id/filters/adguard-tracking-protection.txt) | 2026-06-02, 01:53:08 |
| AdGuard Social Media | [Main URL](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_4_Social/filter.txt) | [Mirror URL](https://hosts.domi.my.id/filters/adguard-social-media.txt) | 2026-06-02, 01:53:08 |
| AdGuard URL Tracking | [Main URL](https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_17_TrackParam/filter.txt) | [Mirror URL](https://hosts.domi.my.id/filters/adguard-url-tracking.txt) | 2026-05-18, 17:41:36 |
| EasyList | [Main URL](https://easylist.to/easylist/easylist.txt) | [Mirror URL](https://hosts.domi.my.id/filters/easylist.txt) | 2026-06-02, 01:53:08 |
| EasyList Cookie List | [Main URL](https://secure.fanboy.co.nz/fanboy-cookiemonster.txt) | [Mirror URL](https://hosts.domi.my.id/filters/fanboy-cookiemonster.txt) | 2026-06-02, 01:53:08 |
| Fanboy's Annoyance List | [Main URL](https://secure.fanboy.co.nz/fanboy-annoyance.txt) | [Mirror URL](https://hosts.domi.my.id/filters/fanboy-annoyance.txt) | 2026-06-02, 01:53:08 |
| Fanboy's Social Blocking List | [Main URL](https://easylist.to/easylist/fanboy-social.txt) | [Mirror URL](https://hosts.domi.my.id/filters/fanboy-social.txt) | 2026-06-02, 01:53:08 |
| HaGeZi's Pro | [Main URL](https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/multi.txt) | [Mirror URL](https://hosts.domi.my.id/filters/hagezi-pro.txt) | 2026-06-02, 01:53:08 |
| OISD Big | [Main URL](https://big.oisd.nl/domainswild) | [Mirror URL](https://hosts.domi.my.id/filters/oisd-big.txt) | 2026-06-02, 01:53:08 |
| Peter Lowe's List | [Main URL](https://pgl.yoyo.org/adservers/serverlist.php?hostformat=adblockplus&showintro=1&mimetype=plaintext) | [Mirror URL](https://hosts.domi.my.id/filters/peter-lowes-list.txt) | 2026-05-29, 18:02:07 |
| ShadowWhisperer - ADS | [Main URL](https://raw.githubusercontent.com/ShadowWhisperer/BlockLists/master/Lists/Ads) | [Mirror URL](https://hosts.domi.my.id/filters/shadowwhisperer-ads.txt) | 2026-06-02, 01:53:08 |
| Steven Black's Hosts | [Main URL](https://raw.githubusercontent.com/StevenBlack/hosts/master/data/StevenBlack/hosts) | [Mirror URL](https://hosts.domi.my.id/filters/steven-blacks-hosts.txt) | 2026-05-26, 17:59:05 |
| URLhaus Malicious URL Blocklist | [Main URL](https://malware-filter.gitlab.io/malware-filter/urlhaus-filter.txt) | [Mirror URL](https://hosts.domi.my.id/filters/urlhaus-malicious.txt) | 2026-06-02, 01:53:08 |

### How It Works

A GitHub Action runs automatically every day to pull the latest raw text files from the URLs listed above. The script strips out the original metadata headers to prevent parsing errors, removes duplicate rules to keep the file lightweight, and compiles everything into the `AIO_Filter_List.txt` file located in the root directory.
