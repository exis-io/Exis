///////////////////////////////////////////////////////////////////////////////
//
//  Generator
//  A helper package for Exis documentation and testing.
//
//  Copyright (C) 2015-2016 Exis
//
///////////////////////////////////////////////////////////////////////////////

function Languages() {
    this.ext2name = {
        py: "python",
        swift: "swift",
        go: "go",
        js: "js"
    }
    this.name2ext = {
        python: "py",
        swift: "swift",
        go: "go",
        js: "js"
    }
}

/**
 * Request objects contain all info needed to Render the code
 * Members:
 *  action     - one of "subscribe", "publish", "register", "call"
 *  endpoint   - the endpoint string
 *      The endpoint to call
 *  wait       - ["str:s", "int:i", "$Student:stu", ...]
 *      "type:name" - type is what type to expect, name is what to call it in the function
 *  want       - ["str:s", "int:i", "$Student:stu", ...]
 *      same as wait above
 *  returns    - ["Hi", 3, 3.2, "$Student:stu"]
 *      What to return back when required
 *  exceptions - true/false
 *      Add the exception handling code or not?
 */
function Request() {
    this.action = null;
    this.endpoint = null;
    this.args = null;
    this.wait = null;
    this.want = null;
    this.returns = null;
    this.exceptions = false;
    this.setupComplete = false;
}

/**
 * Perform some setup on the request object so we can render with
 * less work below (stuff like pull out the names and the types from
 * the want object, etc..)
 */
Request.prototype.setup = function() {
    if(this.setupComplete === true) {
        return;
    }
    var pullNameTypes = function(obj) {
        var names = [];
        var types = [];
        for(var i = 0; i < obj.length; i++) {
            var w = obj[i];
            var sp = w.split(":");
            types[types.length] = sp[0];
            names[names.length] = sp[1];
        }
        obj.names = names;
        obj.types = types;
    }
    function codeFormat(obj) {
        var s = [];
        for(var i = 0; i < obj.length; i++) {
            var r = obj[i];
            if(typeof(r) == "string") {
                s[s.length] = '"' + r + '"';
            }
            else if(typeof(r) == "number") {
                s[s.length] = r;
            }
        }
        return s;
    }
    if(this.want !== null) {
        pullNameTypes(this.want);
    }
    if(this.wait !== null) {
        pullNameTypes(this.wait);
    }
    if(this.returns !== null) {
        this.returns = codeFormat(this.returns);
    }
    if(this.args !== null) {
        this.args = codeFormat(this.args);
    }
    
    this.setupComplete = true;
}

function Coder(req) {
    this.request = req;
}

function isPubCall(a) {
    if(a == "publish" || a == "call")
        return true;
    return false;
}

function isRegSub(a) {
    return !isPubCall(a);
}

function isPub(a) {
    return a == "publish";
}
function isSub(a) {
    return a == "subscribe";
}
function isReg(a) {
    return a == "register";
}
function isCall(a) {
    return a == "call";
}

function quotes(obj) {
    return '"' + obj + '"';
}

function newline(num) {
    return "\n";
}

function tabs(num) {
    return "    ";
}

function capitalize(s) {
    return s.charAt(0).toUpperCase() + s.slice(1);
}
function langRenderTypes(t) {
    return t.join(", ");
}
function langRenderArgs(r) {
    return r.join(", ");
}

///////////////////////////////////////////////////////////////////////////////
// For each language we will define a tree as to how the code should be
// rendered.
///////////////////////////////////////////////////////////////////////////////
/* What the functions look like in Python
=== SUB/REG ===
@want(WANT.types)
def ENDPOINT(WANT.names):
    print WANT.names
    return RETURN
self.ACTION("ENDPOINT", ENDPOINT)

=== CALL ===
WAIT.NAMES = backend.ACTION("ENDPOINT", ARGS).wait(WAIT.types)
print WAIT.names

=== PUB ===
backend.ACTION("ENDPOINT", ARGS)
*/
function Python(request) {
    this.name = "python";
    this.request = request;
    var actionVar = {
        publish: "backend",
        call: "backend",
        register: "self",
        subscribe: "self"
    }
    
    c = new Coder(request);
    c.start = function() {
        var w = (this.request.want !== null) ? this.want() : "";
        var f = (isRegSub(this.request.action)) ? this.func() : "";
        return w + f + this.exisLine();
    }
    c.want = function() {
        return "@want(" + langRenderTypes(this.request.want.types) + ")" + newline();
    }
    c.beforeExisLine = function() {
        if(this.request.action == "call") {
            return this.request.wait.names + " = ";
        } else {
            return "";
        }
    }
    c.exisLine = function() {
        return this.beforeExisLine() + actionVar[this.request.action] + "." + this.request.action + "(" + 
                quotes(this.request.endpoint) + ", " + 
                this.exisArgs() + ")" + this.afterExisLine()
    }
    c.exisArgs = function() {
        if(isPubCall(this.request.action)) {
            return langRenderArgs(this.request.args);
        } else {
            return this.request.endpoint;
        }

    }
    c.afterExisLine = function() {
        if(isCall(this.request.action)) {
            return ".wait(" + langRenderTypes(this.request.wait.types) + ")" + newline() +
            "print " + langRenderArgs(this.request.wait.names);
        } else {
            return "";
        }
    }
    c.func = function() {
        return this.def() +
                this.body() +
                this.returns();
    }
    c.def = function() {
        return "def " + this.request.endpoint + "(" + this.request.want.names + "):" + newline();
    }
    c.body = function() {
        return tabs() + "print " + this.request.want.names + newline();
    }
    c.returns = function() {
        if(this.request.returns === null) {
            return "";
        } else {
            return tabs() + "return " + langRenderArgs(this.request.returns) + newline();
        }
    }

    this.coder = c;
}

///////////////////////////////////////////////////////////////////////////////
/* What the functions look like in JS
=== SUB ===
this.ACTION("ENDPOINT", riffle.want(function (WANT.names) {
    console.log(WANT.names);
}, WANT.types));

=== REG ===
this.ACTION("ENDPOINT", riffle.want(function (WANT.names) {
    console.log(WANT.names);
    return RETURNS;
}, WANT.types));

=== CALL ===
backend.ACTION("ENDPOINT", ARGS).then(riffle.wait(function (WAIT.names) {
    console.log(WAIT.names);
}, WAIT.types),
function (err) {
    console.log("ERROR: ", err);
});

=== PUB ===
backend.ACTION("ENDPOINT", ARGS).then(function () {
    // Done
},
function (err) {
    console.log("ERROR: ", err);
});
*/
function JS(request) {
    this.name = "js";
    this.request = request;
    var actionVar = {
        publish: "backend",
        call: "backend",
        register: "this",
        subscribe: "this"
    }
    function langRenderTypes(t) {

    }
    function langRenderArgs(r) {

    }
    
    c = new Coder(request);
    c.start = function() {
        return this.exisLine();
    }
    c.exisLine = function() {
        return actionVar[this.request.action] + "." + capitalize(this.request.action) + "(" + 
            quotes(this.request.endpoint) + ", " + this.exisArgs() + ");";
    }
    c.exisArgs = function() {
        if(isPubCall(this.request.action)) {
            return this.request.args;
        } else {
            return this.func();
        }
    }
    c.func = function() {
        return "riffle.want(function (" + this.request.want.names + ") {" + newline() + 
            this.body() + "}, " + langRenderTypes(this.request.want.types) + ")";
    }
    c.body = function() {
        return tabs() + "console.log(" + this.request.want.names + ");" + newline() +
            this.returns();
    }
    c.returns = function() {
        if(this.request.returns !== null) {
            return tabs() + "return " + langRenderReturns(this.request.returns) + ";" + newline();
        } else {
            return "";
        }
    }

    this.coder = c;
}

/**
 * Renders the proper code snippets in each language based on the Request object provided.
 * Returns:
 *  Code object with code in each language specified as Code.lang
 */
function Render(request) {
    py = new Python(request);
    js = new JS(request);
    console.log(py.coder.start());
    //console.log(js.coder.start());
}

exports.Render = Render;
exports.Request = Request;
