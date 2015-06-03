#!/bin/sh
set -ex

cd release
bundle exec bosh --non-interactive create release --final --with-tarball

RELEASE_FILE=$(find releases/cf-monggoseim/ -name \*.tgz)
REMOTE_PATH=$(find releases/cf-monggoseim/ -name \*.tgz | xargs basename)
aws s3 cp $RELEASE_FILE s3://cf-monggoseim-internal-builds/monggoseim/$REMOTE_PATH
