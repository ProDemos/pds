PDS - Distribution
=============================

## Releasing

Releasing is done using a Github action, on `Release`. To create a new release, go to \
https://github.com/ProDemos/pds/releases/new

Make sure to use a valid semantic version as a tag name (for NPM).

This triggers a workflow that builds the packages and releases them.

A new release creates either a **npm package** and/or a **github release asset** for every package in the build dir.



## Packaging

Packaging is set up following

https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry#publishing-multiple-packages-to-the-same-repository

To add a completely new package to be created on every release, create new targets in the makefile for `package-YOURPACKAGE` and `release-YOURPACKAGE`

## Releasing manually

If you want to call the `make release $version` target from the command 
line, you can; it would require a  github token with packages 
privileges to be set in  `.npmrc` in this repo; see `.npmrc-dist` 
for an example; and the `hub` command installed. Also a release with
version $version would already have to exist on github.



