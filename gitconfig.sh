#!/bin/bash


NAME="Chad Homan"
EMAIL=choman@gmail.com

git config --global core.editor vi
git config --global push.default simple
git config --local user.name "$NAME"
git config --local user.email "$EMAIL"
git config --local credential.helper cache

git config remote.origin.url https://choman@github.com/choman/freeipa_config.git

