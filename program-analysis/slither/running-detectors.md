### Running a script

To run a python script with python 3:

```bash
python3 script.py
```

### Command line

**Command line versus user-defined scripts.** Slither comes with a set of
predefined detectors that find many common bugs. Calling Slither from the
command line will run all the detectors, no detailed knowledge of static
analysis needed:

```bash
slither project_paths
```

In addition to detectors, Slither has code review capabilities through its
[printers](https://github.com/crytic/slither#printers) and
[tools](https://github.com/crytic/slither#tools).

Use [crytic.io](https://crytic.io) to get access to private detectors and GitHub
integration.
