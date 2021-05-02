#!/bin/sh
find . -name "*.sh" -type f -exec shellcheck {} \;
find . -name "*.sh" -type f -exec shfmt -p {} \; 1>/dev/null