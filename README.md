# kogito-benchmark-automation
Contains all automation tools required to perform a Kogito benchmark test

### Install ansible on operator machine
```
sudo yum update
# on RHEL8 enable repo
sudo subscription-manager repos --enable ansible-2.9-for-rhel-8-x86_64-rpms
# on RHEL7 enable repo
 sudo subscription-manager repos --enable rhel-7-server-ansible-2.9-rpms
# install ansible
sudo yum install ansible 
```
### Install ansible playbook dependencies on host machines
```
# in case python 3 is not installed - if 'python' is pointing to different version then don't forget to set
# ansible_python_interpreter: <python3 install dir> e.g. /usr/bin/python3
# python3 is needed by 'docker sdk for python'
sudo yum install python3

# install pip to install 'docker sdk for python' which is needed for certain docker modules
sudo subscription-manager repos --enable rhel-server-rhscl-7-rpms
--> Repository 'rhel-server-rhscl-7-rpms' is enabled for this system.
sudo yum install python27-python-pip
--> ...  Complete!

# once shell is closed need to run enable command again to be able to use pip
sudo scl enable python27 bash
# check that installed and usable
which pip
--> /opt/rh/python27/root/usr/bin/pip
pip -V
--> pip 8.1.2 from /opt/rh/python27/root/usr/lib/python2.7/site-packages (python 2.7)

# install docker sdk for python
pip install docker
```
ansible-galaxy collection install community.docker
ansible-galaxy collection install containers.podman

### Running tests
- update the inventory file(s) for desired test environment
  - to run ansible operator and host on same machine (e.g. your laptop) edit: 
  `testRunner/env/inventory-local`
  - to run tester and app on separate VMs edit:
  `testRunner/env/inventory-VM1-tester` and `testRunner/env/inventory-VM2-app` 
  - to run tester and app on same the VM edit:
  `testRunner/env/inventory-VM2-tester` and `testRunner/env/inventory-VM2-app` 
  - to run on OCP lab, ...
- if environments are already provisioned, skip ahead; otherwise run playbook `testRunner/envSetup/provision-local-or-VM.yml` (not final)
```shell
ansible-playbook provision-local-or-VM.yml -i ../env/inventory-local -v -K
OR
ansible-playbook provision-local-or-VM.yml -i ../env/inventory-VM1-tester -i ../env/inventory-VM2-app
OR
ansible-playbook provision-local-or-VM.yml -i ../env/inventory-VM2-tester -i ../env/inventory-VM2-app
```
- configure tests
  - edit file `testRunner/test-resources/batch.json`
    - `Tester`: LOCAL|VM1|VM2
    - `App`: LOCAL|VM2|OCP
    - `Infrasetup`: podman|docker
    - `Infra`: lists all supported infra structure components (TODO: currently just Mongo and Postgres) - to use, set value to yes, otherwise to no
    - `Process`: how to access the endpoint that is to be tested
    - `Warmup`: if case a warmup run is to be done before each test run
    - `Tests`: list of tests to be run; replicas field just relevant for OCP, should contain either `requests` or `duration`
  - run script `testRunner/runTests.sh`

