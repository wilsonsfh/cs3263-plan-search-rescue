#!/bin/sh
# Build the Google Docs-ready Word file for Sections 1-3 (open in Drive, then File > Save as Google Docs).
cd "$(dirname "$0")"
python3 architecture.py
cp ../pddl/lambda-sweep/figures/tradeoff.png ../pddl/lambda-sweep/figures/who-left.png figures/
pandoc sections-1-3.md -f markdown -t docx --citeproc --bibliography=references.bib \
  --reference-doc=docx-reference.docx --resource-path=. -o "sections-1-3.docx"
