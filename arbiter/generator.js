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
    
    // Every coder must contain a start function
    c.start = function() {
        return this.wantStr() + this.func() + this.exisLine();
    }
    // How to display the want in this lang
    c.wantStr = function() {
        if(this.want !== null)
            return "@want(" + lang.renderTypes(this.want.types) + ")" + newline();
        else
            return "";
    }
    c.beforeExisLine = function() {
        if(this.isCall()) {
            return this.wait.names + " = ";
        } else {
            return "";
        }
    }
    c.exisLine = function() {
        return this.beforeExisLine() + lang.getActionVar() + "." + this.action + "(" + 
                quotes(this.endpoint) + ", " + 
                this.exisArgs() + ")" + this.afterExisLine()
    }
    c.exisArgs = function() {
        if(this.isPubCall()) {
            return lang.renderArgs(this.args);
        } else {
            return this.endpoint;
        }

    }
    c.afterExisLine = function() {
        if(this.isCall()) {
            return ".wait(" + lang.renderTypes(this.wait.types) + ")" + newline() +
            "print " + lang.renderArgs(this.wait.names);
        } else {
            return "";
        }
    }
    c.func = function() {
        if(this.isRegSub()) {
            return this.def() +
                    this.body() +
                    this.returnStr();
        } else {
            return "";
        }
    }
    c.def = function() {
        return "def " + this.endpoint + "(" + lang.renderArgs(this.want.names) + "):" + newline();
    }
    c.body = function() {
        return tabs() + "print " + lang.renderArgs(this.want.names) + newline();
    }
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
    
    c.start = function() {
        return this.exisLine();
    }
    c.exisLine = function() {
        return lang.getActionVar() + "." + capitalize(this.action) + "(" + 
            quotes(this.endpoint) + ", " + this.exisArgs() + ");";
    }
    c.exisArgs = function() {
        if(this.isPubCall()) {
            return lang.renderArgs(this.args);
        } else {
            return this.func();
        }
    }
    c.func = function() {
        return "riffle.want(function (" + lang.renderArgs(this.want.names) + ") {" + newline() + 
            this.body() + "}, " + lang.renderTypes(this.want.types) + ")";
    }
    c.body = function() {
        return tabs() + "console.log(" + lang.renderArgs(this.want.names) + ");" + newline() +
            this.returnStr();
    }
    c.returnStr = function() {
        if(this.returns !== null) {
            return tabs() + "return " + lang.renderArgs(this.returns) + ";" + newline();
        } else {
            return "";
        }
    }

    this.coder = c;
}

exports.Python = Python;
exports.JS = JS;
