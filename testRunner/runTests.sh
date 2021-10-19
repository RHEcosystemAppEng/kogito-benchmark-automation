#!/bin/sh

BATCH_FILE=test-resources/batch.json
TESTS_FILE=test-resources/tests.json

INFRA=$(jq '.Infra' $BATCH_FILE)
TESTER=$(jq '.Tester' $BATCH_FILE)
APP=$(jq '.App' $BATCH_FILE)

echo "defined INFRA: "$INFRA
echo "TESTER env: "$TESTER
echo "APP env: "$APP

#get environment configuration where test is to be run
INVENTORY_TESTER=""
CMD_LINE_PARAMS_TESTER=" -v "
INVENTORY_APP=""
CMD_LINE_PARAMS_APP=" -v "

if [[ $TESTER = '"LOCAL"' ]] && [[ $APP = '"LOCAL"' ]]
then
  echo "running locally"
  INVENTORY_TESTER="../env/inventory-local"
  CMD_LINE_PARAMS_TESTER=" -v "
  INVENTORY_APP="../env/inventory-local"
  CMD_LINE_PARAMS_APP=" -v -K "
elif [[ $TESTER = '"VM1"' ]] && [ $APP = '"VM2"' ]]
then
  echo "running client on VM1 and app on VM2"
  INVENTORY_TESTER="../env/inventory-VM1-tester"
  INVENTORY_APP="../env/inventory-VM2-app"
elif [[ $TESTER = '"VM2"' ]] && [[ $APP = '"VM2"' ]]
then
  echo "running client and app on VM2"
  INVENTORY_TESTER="../env/inventory-VM2-tester"
  INVENTORY_APP="../env/inventory-VM2-app"
else
   echo "not a valid environment: $TESTER $APP"
   exit
fi

echo "tester inventory: "$INVENTORY_TESTER
echo "tester command line parameters: "$CMD_LINE_PARAMS_TESTER
echo "app inventory: "$INVENTORY_APP
echo "app command line parameters: "$CMD_LINE_PARAMS_APP

#copy all data connected to test (except the data specific per test run) to JMeter of tester host
ansible -i "$INVENTORY_TESTER" tester -m ansible.builtin.copy -a 'src='$BATCH_FILE' dest="{{install_dir}}/kogito-benchmark/test-clients/jmeter-client/test-run"'

NO_OF_TESTS=$(jq '. | length' $TESTS_FILE)
#run tests - checks the env and kicks off the test
while [ $NO_OF_TESTS -gt 0 ]
do
  NO_OF_TESTS=$((NO_OF_TESTS-1))
  #install/deploy/run/validate env
  ansible-playbook prepare-local-or-VM.yml -i $INVENTORY_APP $CMD_LINE_PARAMS_APP -e "$INFRA"
  #run test
  TEST_RUN=$(jq '.['$NO_OF_TESTS']' $TESTS_FILE)
  ansible-playbook runtest-local-or-VM.yml -i $INVENTORY_TESTER $CMD_LINE_PARAMS_TESTER -e 'testreq='"$TEST_RUN"
  #do post processing	
  #kickoff Danieles reporting here???
done

