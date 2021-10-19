###Inventories for different environment configurations
- inventory-local: environment for the tester client and the application on the same machine the playbooks are executed from
- inventory-VM1-tester: remote environment VM1 of the tester client
- inventory-VM2-app: remote environment VM2 of the application
- inventory-VM2-tester: remote environment VM2 of tester in case tester and app run on same remote machine 

To setup which inventory is chosen, edit file `/testRunner/test-resources/batch.json`
