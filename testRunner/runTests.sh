#!/bin/sh

BATCH_FILE=test-resources/batch.json

INFRA=$(jq '.Infra' $BATCH_FILE)
TESTER=$(jq '.Tester' $BATCH_FILE)
APP=$(jq '.App' $BATCH_FILE)

echo "defined INFRA: "$INFRA
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

#pre processing
#setup remote JMeter for new test run - remove any previously created test-run folder
ansible -i "$INVENTORY_TESTER" tester -m ansible.builtin.file -a 'path="{{install_dir}}/kogito-benchmark/test-clients/jmeter-client/test-run" state=absent'
#copy all data connected to test (except the data specific per each test run) to JMeter of tester host
ansible -i "$INVENTORY_TESTER" tester -m ansible.builtin.copy -a 'src='$BATCH_FILE' dest="{{install_dir}}/kogito-benchmark/test-clients/jmeter-client/test-run/"'

TEST_COUNTER=0
NO_OF_TESTS=$(jq '.Tests | length' $BATCH_FILE)
WITH_WARMUP=$(jq -r '.Warmup .enabled' $BATCH_FILE)
#run tests - checks the env and kicks off the test
while [ $TEST_COUNTER -lt $NO_OF_TESTS ]
do
  #install/deploy/run/validate env
  #ansible-playbook prepare-local-or-VM.yml -i $INVENTORY_APP $CMD_LINE_PARAMS_APP -e "$INFRA"
  #run warmup
  if [ $WITH_WARMUP = "yes" ]
  then
    ansible -i "$INVENTORY_TESTER" tester -m ansible.builtin.shell -a "./runTestWarmup.sh "$TEST_COUNTER"; chdir=\"{{install_dir}}/kogito-benchmark/test-clients/jmeter-client\""
  fi
  #kickoff metrics collection - call Lokeshs REST API here - send interval for polling metrics on application, env (Vm or OCP) to use
  #TODO
  #run test - could also be an ad hoc like the warmup call
  ansible-playbook runtest-local-or-VM.yml -i $INVENTORY_TESTER $CMD_LINE_PARAMS_TESTER -e "testidx=$TEST_COUNTER"
  #request accumulated metrics - call Lokeshs REST API here
  #TODO
  TEST_COUNTER=$((TEST_COUNTER+1))
done

#post processing
#copy the remote test_run folder to the reportGenerator after removing any existing
ansible -i "$INVENTORY_TESTER" tester -m ansible.builtin.file -a 'path="../reportGenerator/test-run" state=absent'
ansible -i "$INVENTORY_TESTER" tester -m ansible.builtin.copy -a 'src="{{install_dir}}/kogito-benchmark/test-clients/jmeter-client/test-run" dest=../reportGenerator'
#kickoff Danieles reporting here???
#TODO