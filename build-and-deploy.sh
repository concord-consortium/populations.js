#!/bin/sh

git diff --exit-code > /dev/null && git diff --staged --exit-code > /dev/null
if [[ $? != 0 ]] ; then
    echo "There are uncommitted changes to the git repo! git status:"
    git status
    exit 1
fi

export COMMIT=`git log -1 --format=%H`

echo "changing to toplevel directory"
cd $(git rev-parse --show-toplevel)

echo "Building application... "
rm -rf public
node_modules/.bin/brunch build


echo "Committing contents of public folder"

cp -r public/ tmp/
cd tmp
git init .
git add .
git commit -m "deploy $COMMIT"

echo "Pushing to gh-pages"
git push "git@github.com:concord-consortium/populations.js.git" master:gh-pages --force

cd ..
rm -rf tmp
