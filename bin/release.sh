#!/bin/bash

set -e

if [ -n "$1" ]; then
  echo "Version $1"

  git checkout develop
  git pull

  # Update version in lib/easy_retry/version.rb
  sed -i '' -e "s/\(VERSION = \).*/\1\"$1\"/" lib/easy_retry/version.rb
  git commit -am "Prepare for release $1"

  git tag $1
  git push origin develop
  git push --tags

  git checkout main
  git pull
  git merge $1
  git push

  gem build easy_retry.gemspec
  gem push easy_retry-$1.gem

  mv easy_retry-$1.gem pkg/easy_retry-$1.gem
else
  echo "Usage: $0 <version>"
fi
