# kogito-benchmark-automation
Contains all automation tools required to perform a Kogito benchmark test

## Install Automation Dependencies
### Install Ansible on controller machine
```
sudo yum update
# on RHEL8 enable repo
sudo subscription-manager repos --enable ansible-2.9-for-rhel-8-x86_64-rpms
# on RHEL7 enable repo
 sudo subscription-manager repos --enable rhel-7-server-ansible-2.9-rpms
# install ansible
sudo yum install ansible 
# install extra ansible modules
ansible-galaxy collection install community.docker
ansible-galaxy collection install containers.podman
ansible-galaxy collection install community.general
```
### Install JQ on controller and tester machine
JQ is used in most of the runXXX.sh scripts to parse the batch.json configuration file 
```
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum update
sudo yum install  jq
```

### Install Ansible playbook dependencies on host machines
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


## Running tests
- update the inventory file `testRunner/env/inventory`
- if environments are already provisioned, skip ahead; 
  otherwise run script `envSetup/runSetup.sh` (not final)
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

