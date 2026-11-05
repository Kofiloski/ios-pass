#!/bin/bash

PATH=/opt/homebrew/bin/:$PATH

if [[ "${SKIP_SWIFTFORMAT:-0}" == "1" ]]; then
  echo "Skipping source formatting for the public Simulator check."
  exit 0
fi

if which swiftformat >/dev/null; then
  swiftformat .
else
  echo "warning: SwiftFormat not installed, download from https://github.com/nicklockwood/SwiftFormat"
fi
