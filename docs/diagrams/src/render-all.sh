#!/usr/bin/env sh
# Render every usage diagram to SVG in the parent directory, where the READMEs
# reference them. SVG rather than PNG so the text stays selectable and the file
# stays diffable.
set -eu
cd "$(dirname "$0")"
plantuml -tsvg -o .. ./*.puml
echo "Rendered: $(ls -1 ../usage*.svg | wc -l) diagrams"
