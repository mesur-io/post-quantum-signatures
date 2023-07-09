#!/bin/bash

echo "========== NOTE: '\\' line wrapping per RFC 8792 =========="
while IFS= read -r input; do
  line_length=${#input}
  while [[ $line_length -gt 68 ]]; do
    line="${input:0:68}\\"
    echo "$line"
    input="${input:68}"
    line_length=${#input}
  done
  echo "$input"
done
