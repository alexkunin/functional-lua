#!/usr/bin/env bash

dir=.
build_dir=$dir/build
src_dir=$dir/src
build=$build_dir/bundle.lua

echo "Building ${build}..."

files=$(find $src_dir -name '*.lua')

mkdir -p $build_dir

(
  modules=$(
    for file in $files; do
      ns=${file#$src_dir/}
      ns=${ns%.lua}
      ns=${ns//\//.}
      echo -e "[\"$ns\"]=function (...)\n$(cat "$file")\nend,"
    done
  )

  bootstrap=$(cat bootstrap.lua)

  bundle=${bootstrap/\[==\[MODULES\]==\]/$modules}
  bundle=${bundle/\[==\[ENTRY_POINT\]==\]/addon}

  echo "$bundle"
) >$build

echo "All done."
