#!/bin/sh

BATCH_FILE=test-resources/batch.json

TESTER=$(jq -r '.InfraSetup.tester.name' $BATCH_FILE)
APP=$(jq -r '.InfraSetup.app.name' $BATCH_FILE)

echo "TESTER env: "$TESTER
echo "APP env: "$APP

CMD_LINE_PARAMS=" -v "
if [[ $APP = 'LOCAL' ]]
then
  CMD_LINE_PARAMS=" -v -K "
fi
echo "app command line parameters: "$CMD_LINE_PARAMS

ansible-playbook provision-local-or-VM.yml -i "env/inventory" $CMD_LINE_PARAMS -e "app=$APP tester=$TESTER"