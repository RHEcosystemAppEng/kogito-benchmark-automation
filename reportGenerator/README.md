# Setup Python environment
Install Python 3:
```shell
sudo yum install python3
sudo yum install python3-pip
```

Create a `virtualenv` under the current folder and install needed requirements from [requirements.txt](./requirements.txt):
```shell
python3 -m venv kogito-venv
source kogito-venv/bin/activate

pip install --upgrade pip
pip3 install -r requirements.txt
```

# Generate report document
Requirements:
* Generated CSV is named `rawdata.csv` and has the same content as in the given template [rawdata.csv](./rawdata.csv)
* Execution properties are located in a file named `execution.properties` and has the same content as in the given template [execution.properties](./execution.properties)

This command creates the HTML report starting from the above requirements:
```shell
python3 -m jupyter nbconvert --execute benchmarkReport.ipynb --to html --no-input
```

Use `open benchmarkReport.html` to show the generated report on the default browser.

# Developing with VS Code
Requirements:
* `Jupyter` extension
* `Python` extension

Steps:
* `View > Command Palette` (SHIFT-CMD-P) run `Python: Select Interpreter`
* Add the new interpreter located at `./kogito-venv/bin/python3.9` (use the absolute path)
* Open the Jupyter Notebook [benchmarkReport.ipynb](benchmarkReport.ipynb)
* Select the Python Kernel from the status bar, using the newly added interpreter
