#!/bin/sh

set -x

mkdir -p test_results/

# Do not run kerl activate in Bash strict mode or will give error.
. /var/erlang/17.4/activate

set -e

printf "blobstore:\n  s3:\n    access_key_id: ${AWS_ACCESS_KEY_ID}\n    secret_access_key: ${AWS_SECRET_ACCESS_KEY}\n" > release/config/private.yml

erl -pa test -noshell -eval '{_Ok, Failed, {_UserSkipped, _AutoSkipped}} = ct_run:run_test([{dir, "test"}, {suite, "mongooseim_deployed"}, {logdir, "test_results"}]), erlang:halt(Failed).'
