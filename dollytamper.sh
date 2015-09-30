#! /bin/bash

hash="$(cat `grep -rl '"name": "dolly"' /var/lib/registry/docker/registry/v2/` | grep Sum | head -n1 | cut -d':' -f3 | cut -d'"' -f1)"
firstchars="$(echo $hash | head -c 2)"
data="/var/lib/registry/docker/registry/v2/blobs/sha256/$firstchars/$hash/"
echo $data
