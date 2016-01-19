# Arbiter

A system to help test and self document all of our supported languages. The documentation is supported by the `DocGen` service in our docs repo as well as the `exis-code` directive.

Arbiter scans all code files (based on extensions `*.py`, `*.swift`, etc..) and looks for comment strings in that specific language (`#` for Python, `//` for JS or Swift, etc..). **Note that below I may show examples with comments using `#` for Python, just replace with the language-specific comment character**

**Notes:**

1. Multi-line comments or comment blocks `denoted by /* and */` are not supported yet.
2. You must have our (private) coreappliances repo setup, and point to it with `EXIS_APPLIANCES` env var.


## In-code specification

Arbiter defines a specific way to read structured comments so that we can cherry pick individual test cases for both actual testing as well as documentation.

Very complex tests can be understood by Arbiter (these are called `Tasks`), as long as it contains the following:
```
# Example Test Name - documenting string
<code>
# End Example Test Name
```

**There are a few specific options described below.**

### Expects

In order to allow Arbiter to run tests and check the results the code must define what it expects to see, these are handled as special expects comments.

For example, this code in python will make sure the value passed as an argument is a "Hello World" string.

```
@want(str)
def func(s):
    print s # Expects a str, like "Hello World"
```

**Note that the comment must show up on the same line as a print statement**

### Set action

There are cases where we want to scan a chunk of code but don't want to execute it or it doesn't have a well defined action. In this case you would add a `# ARBITER set action <name>` comment line at the beginning of the Task.

Example:
```
# Example Want Definitions - these are some want definitions for python
# ARBITER set action defs
from riffle import want

@want(str)
@want(int)
...
# End Example Want Definitions
```

In this example, we could view the documentation with the following tag in our docs:
```
<exis-code name="Want Definitions" action="defs"></exis-code>
```


## Command line usage

### View examples

* `python arbiter.py -f findTasks` : shows you all tasks
* `python arbiter.py -f findTasks -a python` : shows you all python tasks

### Documentation

Calling `python arbiter.py -f genDocs > exisdocs.json` will create a JSON object that can be dropped into the `/static` folder of our exis-io docs repo.

### Testing

**Usage:**
```
-f test -a <TASK> -a <TASK2> ...
Where TASK is: "language action:Test Name"
```

Calling `python arbiter.py -f test -a "python subscribe:Pub/Sub Basic" -a "python publish:Pub/Sub Basic"` will execute the `Pub/Sub Basic` test
