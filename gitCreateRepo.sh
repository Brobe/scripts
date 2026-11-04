#!/usr/bin/env bash

git init
git add .
git commit -m "batman"
echo -n "Repo name: "
read repo_name
gh repo create $repo_name --private --source=. --remote=origin --push
