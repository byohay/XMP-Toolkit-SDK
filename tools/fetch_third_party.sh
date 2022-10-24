#!/bin/bash
set -e

gh api https://api.github.com/repos/madler/zlib/tarball/v1.2.8 | tar -zx --strip-components 1 -C third-party/zlib/
gh api https://api.github.com/repos/libexpat/libexpat/tarball/R_2_4_7 | tar -zx --strip-components 2 -C third-party/expat/
