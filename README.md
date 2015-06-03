Bosh release for MongooseIM.
========================

Built following this guide:
https://bosh.io/docs/create-release.html

Tests against microbosh.
* https://bosh.io/docs/deploy-microbosh-to-aws.html
* http://docs.cloudfoundry.org/deploying/ec2/aws_steps.html
* bundle install
* BOSH_TARGET=<BOSH IP> BOSH_INSTANCE_SSH_KEY=~/bosh.pem AWS_ACCESS_KEY_ID=XXXX AWS_SECRET_ACCESS_KEY=XXX ./script/test_bosh_release.sh




Test agains boshlite running in Vagrant
* https://blog.starkandwayne.com/2014/12/16/running-cloud-foundry-locally-with-bosh-lite/
* git clone https://github.com/cloudfoundry/bosh-lite.git
* cd bosh-lite
* vagrant up
* bosh download public stemcell bosh-stemcell-389-warden-boshlite-ubuntu-trusty-go_agent.tgz
* bosh upload stemcell bosh-stemcell-389-warden-boshlite-ubuntu-trusty-go_agent.tgz
* bin/add-route

* In cf-mongooseim run ./update to get all submodules 
* Run test: BOSH_TARGET=192.168.50.4  AWS_ACCESS_KEY_ID=XXXX AWS_SECRET_ACCESS_KEY=XXXX ./script/test_bosh_release.sh
