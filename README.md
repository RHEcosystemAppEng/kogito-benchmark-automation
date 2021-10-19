# kogito-benchmark-automation
Contains all automation tools required to perform a Kogito benchmark test

### Running tests
- update the inventory file(s) for desired test environment
- if environments are already provisioned, skip ahead; otherwise run playbook `envSetup/provision-local-or-VM.yml`
```shell
ansible-playbook provision-local-or-VM.yml -i inventory-local -v -K
OR
ansible-playbook provision-local-or-VM.yml -i inventory-VM1-tester -i inventory-VM2-app
OR
ansible-playbook provision-local-or-VM.yml -i inventory-VM2-tester -i inventory-VM2-app
```
- to restart/reset/validate the test env and run a test batch
  - edit files `testRunner/test-resources/batch.json` and `testRunner/test-resources/test.json` 
  - run script `testRunner/runTests.sh`
