#!/bin/bash
#Author:Rohtash Lakra
git config --global user.email "rslakra@users.noreply.github.com"
git config --list --show-origin
git rebase -i
git commit --amend --reset-author
git rebase --continue
git push
echo
