#!/usr/bin/env bash

dir=.
build_dir=$dir/build
deploy_dir=/Volumes/NewAddonTest

echo "Deploying to ${deploy_dir}..."

cp -vr $build_dir/* $deploy_dir

echo "All done."
