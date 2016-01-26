# Arbiter

A system to help test and self document all of our supported languages. The documentation is supported by the `DocGen` service in our docs repo as well as the `exis-code` directive.

Arbiter scans all code files (based on extensions `*.py`, `*.swift`, etc..) and looks for comment strings in that specific language (`#` for Python, `//` for JS or Swift, etc..). **Note that below I may show examples with comments using `#` for Python, just replace with the language-specific comment character**

**Notes:**

1. Multi-line comments or comment blocks `denoted by /* and */` are not supported yet.
2. Race conditions are very possible here, I tried the best I could to mitigate them but if something is acting funny (say lang to lang testing) then try the same test within the same language. For example I ran a test registering in nodejs and calling in python - the setup process for nodejs is much slower than python so the call happened too quickly, adding a very short delay seemed to fix this issue for the time being.

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

**Advanced code snippets** The `set actions` option helps arbiter when your snippets contain multiple actions together, otherwise arbiter won't know what to focus on.

## Command line usage

### View examples

* `python arbiter.py -f findTasks` : shows you all tasks
* `python arbiter.py -f findTasks -a python` : shows you all python tasks
* `python arbiter.py -f findTask -a python -a "Task Name"` : shows you the task, along with the actual code printed

### Documentation

Calling `python arbiter.py -f genDocs > exisdocs.json` will create a JSON object that can be dropped into the `/static` folder of our exis-io docs repo.

### Testing

**Usage:**
```
-f test -a <TASK> -a <TASK2> ...        : Execute TASKS in order, fully specified (see below)
-f test -kw lang=<LANG> -a "Test Name"  : Specify the lang, then all you need to do is name the test (don't need to specify the action, etc..)
```
* TASK : "language action:Test Name"

#### Browser testing

If you have python selenium installed, you can run browser testing via FireFox.
**NOTE** that because we have to launch (at least) one browser, this test takes much longer than regular testing.

* `python arbiter.py -f test -a "python subscribe:Pub/Sub Basic" -a "browser publish:Pub/Sub Basic"`

#### Examples

Both of these examples run the same test:
* `python arbiter.py -f test -a "python subscribe:Pub/Sub Basic" -a "python publish:Pub/Sub Basic"`
* `python arbiter.py -f test -kw lang=python -a "Pub/Sub Basic"`

## Node

The arbiter can start a `node` to provide special types of local testing.

Usage: `python arbiter.py -node ...`

When this happens, you can actually restart the node from within the task. This helps us test specific cases to validate our reconnecting logic.

To do this, simply print `___NODERESTART___` from within the test code:

```
// register a function somewhere:
console.log("___NODERESTART___"); // Restart before a register??
this.Register("someEndpoint", function(a) {
    console.log("___NODERESTART___"); // Restart while responding with a register?
    return a;
});

//... somewhere else in the code

console.log("___NODERESTART___"); // Restart before making a call?
backend.Call("someEndpoint", "arg1").then(function(s) {
    console.log(s);
}, function(err) {
    console.log(err);
});

console.log("___NODERESTART___"); // Restart just before a join?
backend.Join()

```







