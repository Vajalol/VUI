#!/bin/bash

# Find all files with the problematic pattern and fix them
find . -name "*.lua" -exec grep -l "Fallback for test environmentsif" {} \; | while read file; do
  echo "Fixing $file"
  sed -i 's/-- Fallback for test environmentsif/-- Fallback for test environments\nif/g' "$file"
done

echo "All files fixed"