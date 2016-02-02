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

### Timing options

For testing we should be able to make the node restart more async and less deterministic, to deal with this I have added 2 options, like this `___NODERESTART___,opt:#,opt:#`

* `in:#` - specify to restart a node in X sec after this restart command is seen
* `wait:#` - after killing the node, wait X sec before restarting it

```
console.log("___NODERESTART___,in:0.5,wait:0.5");
```

### Debug

Timing issues between these tasks are very difficult, to deal with this I added a `-debug` flag, this will print a summary of events ordered by time between the caller/callee and node if one was running.

Here is some example output:

```
dale@dale-desktop:~/exis/Exis$ python arbiter/arbiter.py -f test -kw lang=nodejs -a "Tour Reg/Call Lesson 1" -debug -node
-- Fri Jan 29 18:34:39 2016 Starting the node
register  call  
1454114079.9743190 out        node : Environment: EXIS_KEY= (DEFAULT)
1454114079.9743221 out        node : Environment: EXIS_PERMISSIONS=off (SET)
1454114079.9743230 out        node : Environment: EXIS_AUTHENTICATION=off (SET)
1454114079.9743240 out        node : Environment: EXIS_CERT= (DEFAULT)
1454114079.9744380 out        node : [2016-01-29 18:34:39.974 LoadConfig] Loaded configuration file: config.json
1454114079.9744780 out        node : [2016-01-29 18:34:39.974 (*node).Handshake] Session open: xs.node
1454114079.9745409 out        node : [2016-01-29 18:34:39.974 (*node).Listen] Request rate limit for xs.node: 1000/s
1454114079.9745800 out        node : [2016-01-29 18:34:39.974 (*node).LogMessage] REGISTER xs.node/getUsage from xs.node
1454114079.9745829 out        node : [2016-01-29 18:34:39.974 (*node).LogMessage] REGISTER xs.node/evictDomain from xs.node
1454114079.9746101 out        node : [2016-01-29 18:34:39.974 (*node).LogMessage] REGISTER xs.node/unregisterAll from xs.node
1454114080.5112591 out    register : ___BUILDCOMPLETE___
1454114080.5117581 out    register : /usr/bin/nodejs
1454114081.0783939 out    register : Creating domain xs.demo.test
1454114081.0795760 out    register : Creating domain xs.demo.test.example
1454114081.0798769 out    register : Creating domain xs.demo.test.example
1454114081.1079111 out    register : Sending HELLO: &{xs.demo.test.example map[authid:xs.demo.test.example authmethods:[]]}
1454114081.1117570 out        node : [2016-01-29 18:34:41.111 (*node).Handshake] Session open: xs.demo.test.example
1454114081.1119101 out        node : [2016-01-29 18:34:41.111 (*node).Listen] Request rate limit for xs.demo.test.example: 20/s
1454114081.1209941 out    register : Domain joined
1454114081.1214671 out    register : ___SETUPCOMPLETE___
1454114081.1229241 out    register : Sending REGISTER: &{8273074849841152 map[] xs.demo.test.example/myFirstFunc}
1454114081.1234491 out        node : [2016-01-29 18:34:41.123 (*node).LogMessage] REGISTER xs.demo.test.example/myFirstFunc from xs.demo.test.example
1454114081.1264949 out    register : Received REGISTERED: &{8273074849841152 3680082426551572}
1454114081.1271360 out    register : Registered: xs.demo.test.example/myFirstFunc [str]
1454114081.2714961 out        call : ___BUILDCOMPLETE___
1454114081.2719350 out        call : /usr/bin/nodejs
1454114081.8311751 out        call : Creating domain xs.demo.test
1454114081.8324130 out        call : Creating domain xs.demo.test.example
1454114081.8327291 out        call : Creating domain xs.demo.test.example
1454114081.8602190 out        call : Sending HELLO: &{xs.demo.test.example map[authid:xs.demo.test.example authmethods:[]]}
1454114081.8640950 out        node : [2016-01-29 18:34:41.864 (*node).Handshake] Session open: xs.demo.test.example
1454114081.8641980 out        node : [2016-01-29 18:34:41.864 (*node).Listen] Request rate limit for xs.demo.test.example: 20/s
1454114081.8734250 out        call : Domain joined
1454114081.8741789 out        call : ___SETUPCOMPLETE___
1454114081.8750360 out        call : Calling xs.demo.test.example/myFirstFunc [Hello]
1454114081.8760190 out        call : Sending CALL: &{379302929498112 map[] xs.demo.test.example/myFirstFunc [Hello] map[]}
1454114081.8768699 out        node : [2016-01-29 18:34:41.876 (*node).LogMessage] CALL xs.demo.test.example/myFirstFunc from xs.demo.test.example
1454114081.8814471 out    register : Received INVOCATION: &{1357629075020686 3680082426551572 map[] [Hello] map[]}
1454114081.8825200 out    register : Hello
1454114081.8830991 out    register : Sending YIELD: &{1357629075020686 map[] [Hello World] map[]}
1454114081.8841391 out        node : [2016-01-29 18:34:41.884 (*node).LogMessage] YIELD from xs.demo.test.example
1454114081.8876929 out        call : Received RESULT: &{379302929498112 map[] [Hello World] map[]}
1454114081.8884699 out        call : Hello World
-- Fri Jan 29 18:34:42 2016 Killing the node
```

