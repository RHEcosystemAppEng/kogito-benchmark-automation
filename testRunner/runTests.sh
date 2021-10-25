#!/bin/sh

BATCH_FILE=test-resources/batch.json

TESTER=$(jq '.Tester' $BATCH_FILE)
APP=$(jq '.App' $BATCH_FILE)

echo "TESTER env: "$TESTER
echo "APP env: "$APP

#set environment configuration where test is to be run
INVENTORY_TESTER=""
CMD_LINE_PARAMS_TESTER=" -v "
INVENTORY_APP=""
CMD_LINE_PARAMS_APP=" -v "
if [[ $TESTER = '"LOCAL"' ]] && [[ $APP = '"LOCAL"' ]]
then
  echo "running locally"
  INVENTORY_TESTER="env/inventory-local"
  CMD_LINE_PARAMS_TESTER=" -v "
  INVENTORY_APP="env/inventory-local"
  CMD_LINE_PARAMS_APP=" -v -K "
elif [[ $TESTER = '"VM1"' ]] && [[ $APP = '"VM2"' ]]
then
  echo "running client on VM1 and app on VM2"
  INVENTORY_TESTER="env/inventory-VM1-tester"
  INVENTORY_APP="env/inventory-VM2-app"
elif [[ $TESTER = '"VM2"' ]] && [[ $APP = '"VM2"' ]]
then
  echo "running client and app on VM2"
  INVENTORY_TESTER="env/inventory-VM2-tester"
  INVENTORY_APP="env/inventory-VM2-app"
else
   echo "not a valid environment: $TESTER $APP"
   exit
fi

echo "tester inventory: "$INVENTORY_TESTER
echo "tester command line parameters: "$CMD_LINE_PARAMS_TESTER
echo "app inventory: "$INVENTORY_APP
echo "app command line parameters: "$CMD_LINE_PARAMS_APP

# pre processing
# setup remote benchmark host for test run - remove any previously created test-run folder
ansible -i "$INVENTORY_TESTER" tester -m ansible.builtin.file -a 'path="{{install_dir}}/kogito-benchmark/test/test-run" state=absent'
# copy new test data to benchmark host
ansible -i "$INVENTORY_TESTER" tester -m ansible.builtin.copy -a 'src='$BATCH_FILE' dest="{{install_dir}}/kogito-benchmark/test/test-run/"'

TEST_COUNTER=0
NO_OF_TESTS=$(jq '.Tests | length' $BATCH_FILE)
while [ $TEST_COUNTER -lt $NO_OF_TESTS ]
do
  # install/deploy/run
  ansible-playbook prepare-local-or-VM.yml -i $INVENTORY_APP $CMD_LINE_PARAMS_APP -e "testdefs=$BATCH_FILE"
  # run test - could also be an ad hoc
  ansible-playbook runtest-local-or-VM.yml -i $INVENTORY_TESTER $CMD_LINE_PARAMS_TESTER -e "testclient=JMETER testidx=$TEST_COUNTER"
  TEST_COUNTER=$((TEST_COUNTER+1))
done

# post processing
ansible -i "$INVENTORY_TESTER" tester -m ansible.builtin.file -a 'path="../reportGenerator/test-run" state=absent'
ansible -i "$INVENTORY_TESTER" tester -m ansible.builtin.copy -a 'src="{{install_dir}}/kogito-benchmark/test/test-run" dest=../reportGenerator'
# kickoff Danieles reporting here???
#TODO