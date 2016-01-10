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

function Coder(req) {
    this.action = null;
    this.endpoint = null;
    this.args = null;
    this.wait = null;
    this.want = null;
    this.returns = null;
    this.exceptions = false;
    req.inherit(this);
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

/**
 * Generic language class with a bunch of functions
 * that might need to be overloaded depending on the lang chosen.
 */
function Language(lang) {
    this.typeStringMap = {
        str: "str",
        int: "int",
        float: "float",
        list: "list",
        bool: "bool",
        dict: "dict"
    };
    
    
    for(var p in Language.prototype) {
        lang[p] = Language.prototype[p];
    }
}
Language.prototype = {
    getActionVar: function() {
        return this.actionVars[this.req.action];
    },
    renderTypes: function(t) {
        return t.join(", ");
    },
    renderArgs: function(r) {
        return r.join(", ");
    },
    /**
     * Actual function that creates the code snippet
     */
    generate: function() {
        return this.coder.start();
    },
    properTypeStr: function(t) {
        return this.typeStringMap[t];
    }
};

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
    Language(this);
    
    this.name = "python";
    this.req = request.copy();
    
    this.actionVars = {
        publish: "backend",
        call: "backend",
        register: "self",
        subscribe: "self"
    }

    // Use our prototype functions to setup things for the Request
    var lang = this;
    c = new Coder(this.req);
    this.req.setup(c, this);
    
    // This coder represents a context-free grammar style definition
    // of how to render JS code based on the Request provided.
    
    // Every coder must contain a start function
    // start: want func exisLine
    c.start = function() {
        return this.wantStr() + this.func() + this.exisLine();
    }
    // want: @want(WANT.types)
    c.wantStr = function() {
        if(this.want !== null)
            return "@want(" + lang.renderTypes(this.want.types) + ")" + newline();
        else
            return "";
    }
    // beforeExis: arg0, arg1, ... = exisLine
    c.beforeExisLine = function() {
        if(this.isCall()) {
            return this.wait.names + " = ";
        } else {
            return "";
        }
    }
    // exisLine: beforeExisLine self.ACTION(ENDPOINT, exisArgs) afterExisLine
    c.exisLine = function() {
        return this.beforeExisLine() + lang.getActionVar() + "." + this.action + "(" + 
                quotes(this.endpoint) + ", " + 
                this.exisArgs() + ")" + this.afterExisLine()
    }
    // exisArgs: ARGS | ENDPOINT
    c.exisArgs = function() {
        if(this.isPubCall()) {
            return lang.renderArgs(this.args);
        } else {
            return this.endpoint;
        }

    }
    // afterExisLine: wait(WAIT.types) \n print WAIT.names
    c.afterExisLine = function() {
        if(this.isCall()) {
            return ".wait(" + lang.renderTypes(this.wait.types) + ")" + newline() +
            "print " + lang.renderArgs(this.wait.names);
        } else {
            return "";
        }
    }
    // func: def body returnStr
    c.func = function() {
        if(this.isRegSub()) {
            return this.def() +
                    this.body() +
                    this.returnStr();
        } else {
            return "";
        }
    }
    // def: def ENDPOINT(WANT.names):
    c.def = function() {
        return "def " + this.endpoint + "(" + lang.renderArgs(this.want.names) + "):" + newline();
    }
    // body: print WANT.names
    c.body = function() {
        return tabs() + "print " + lang.renderArgs(this.want.names) + newline();
    }
    // returnStr: return RETURNS
    c.returnStr = function() {
        if(this.returns === null) {
            return "";
        } else {
            return tabs() + "return " + lang.renderArgs(this.returns) + newline();
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
    Language(this);
    
    this.name = "js";
    this.req = request.copy();
    
    this.typeStringMap = {
        str: "String",
        int: "Number",
        float: "Number",
        list: "Array",
        bool: "Boolean",
        dict: "Object"
    };
    
    this.actionVars = {
        publish: "backend",
        call: "backend",
        register: "this",
        subscribe: "this"
    }

    // Use our prototype functions to setup things for the Request
    var lang = this;
    c = new Coder(this.req);
    this.req.setup(c, this);

    // This coder represents a context-free grammar style definition
    // of how to render JS code based on the Request provided.
    
    // Always a starting function
    c.start = function() {
        return this.exisLine();
    }
    // exisLine: this.ACTION(ENDPOINT, exisArgs) afterExis;
    c.exisLine = function() {
        return lang.getActionVar() + "." + capitalize(this.action) + "(" + 
            quotes(this.endpoint) + ", " + this.exisArgs() + ")" + this.afterExis() + ";";
    }
    // exisArgs: ARGS | func
    c.exisArgs = function() {
        if(this.isPubCall()) {
            return lang.renderArgs(this.args);
        } else {
            return this.func();
        }
    }
    // func: riffle.want(... ( WANT.names ) { \n body }, WANT.types )
    c.func = function() {
        return "riffle.want(function (" + lang.renderArgs(this.want.names) + ") {" + newline() + 
            this.body() + "}, " + lang.renderTypes(this.want.types) + ")";
    }
    // body: console.log(WANT.names); \n returnStr
    c.body = function() {
        return tabs() + "console.log(" + lang.renderArgs(this.want.names) + ");" + newline() +
            this.returnStr();
    }
    // returnStr: return RETURNS;
    c.returnStr = function() {
        if(this.returns !== null) {
            return tabs() + "return " + lang.renderArgs(this.returns) + ";" + newline();
        } else {
            return "";
        }
    }
    // afterExis: .then(riffle.wait(function(WAIT.names) { console.log(WAIT.names); }, WAIT.types, afterExisErr
    c.afterExis = function() {
        if(this.isCall()) {
            return ".then(riffle.wait(function(" + lang.renderArgs(this.wait.names) + ") {" + newline() +
                    tabs() + "console.log(" + lang.renderArgs(this.wait.names) + ");" + newline() +
                    "}, " + lang.renderTypes(this.wait.types) + "), " + this.afterExisErr() + ")";
        } else {
            return "";
        }
    }
    c.afterExisErr = function() {
        return "function(err) {" + newline() +
                tabs() + 'console.log("ERROR: " + err);' + newline() + "}";
    }

    this.coder = c;
}

exports.Python = Python;
exports.JS = JS;
