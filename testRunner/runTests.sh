#!/bin/sh

BATCH_FILE=test-resources/batch.json

TESTER=$(jq -r '.InfraSetup.tester.name' $BATCH_FILE)
APP=$(jq -r '.InfraSetup.app.name' $BATCH_FILE)

echo "TESTER env: "$TESTER
echo "APP env: "$APP

CMD_LINE_PARAMS_TESTER=" -v "
CMD_LINE_PARAMS_APP=" -v "
if [[ $APP = 'LOCAL' ]]
then
  CMD_LINE_PARAMS_APP=" -v -K "
fi
echo "app command line parameters: "$CMD_LINE_PARAMS_APP

# pre processing
# setup remote benchmark host for test run - remove any previously created test-run folder
ansible $TESTER -i "env/inventory" -m ansible.builtin.file -a 'path="{{install_dir}}/kogito-benchmark/test/test-run" state=absent'
# copy new test data to benchmark host
ansible $TESTER -i "env/inventory" -m ansible.builtin.copy -a 'src='$BATCH_FILE' dest="{{install_dir}}/kogito-benchmark/test/test-run/"'

TEST_COUNTER=0
NO_OF_TESTS=$(jq '.Tests | length' $BATCH_FILE)
while [ $TEST_COUNTER -lt $NO_OF_TESTS ]
do
  # install/deploy/run
  ansible-playbook prepare-local-or-VM.yml -i "env/inventory" $CMD_LINE_PARAMS_APP -e "app=$APP testdefs=$BATCH_FILE"

  # run test - could also be an ad hoc
  ansible-playbook runtest-local-or-VM.yml -i "env/inventory" $CMD_LINE_PARAMS_TESTER -e "tester=$TESTER testclient=JMETER testidx=$TEST_COUNTER"
  TEST_COUNTER=$((TEST_COUNTER+1))
done

# post processing
ansible-playbook posttest-local-or-VM.yml -i "env/inventory" $CMD_LINE_PARAMS_TESTER -e "controller=LOCAL tester=$TESTER"
#TODO




