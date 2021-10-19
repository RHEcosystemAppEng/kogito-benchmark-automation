### Test data

`batch.json`: File containing all environment and batch related test execution data
`tests.json`: File containing the test runs

`batch.json`:
- `Infra`: complete list of all possible infra structure components; those to be setup will be marked "yes", those to be not used will be marked "no"
- `Tester`: LOCAL | VM1 | VM2 
- `App`: LOCAL | VM2 | OCP  (OCP not yet implemented)
- `Process`: business process endpoint data 

`tests.json`:

each test run data contains either:
{"replicas":"1", "users":"1", "requests":"2000"},
or
{"replicas":"1", "users":"1", "duration":"2"},