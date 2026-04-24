<br />
<h1 align="center">AIO Filter List</h1>
<br />
Before you dive in, I want to make it absolutely clear that I do not claim ownership or take any credit for the filter rules found in this repository. I did not write them, and I do not maintain the original blocklists.

This project is simply an automated aggregation tool. It routinely fetches, cleans, and merges several highly respected community filter lists into a single file for my own convenience, and I am making it public in case others find it useful.

All credit belongs entirely to the original authors and the communities that spend their time keeping these web filters updated. If you appreciate the ad-blocking and privacy protection provided here, please support the upstream maintainers.

### Direct Access

https://hosts.domi.my.id/AIO_Filter_List.txt

### Upstream Sources

This repository is built on the hard work of the following projects. Here is the exact list of sources pulled during the automation process:

### How It Works

A GitHub Action runs automatically every day to pull the latest raw text files from the URLs listed above. The script strips out the original metadata headers to prevent parsing errors, removes duplicate rules to keep the file lightweight, and compiles everything into the AIO_Filter_List.txt file located in the root directory.
