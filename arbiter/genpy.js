///////////////////////////////////////////////////////////////////////////////
//
//  GenPy
//  A helper package for Exis documentation and testing.
//
//  Copyright (C) 2015-2016 Exis
//
///////////////////////////////////////////////////////////////////////////////

var r = require('./genlang');
var Language = r.Language;
var Coder = r.Coder;


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
            return "@want(" + lang.renderTypes(this.want.types) + ")" + lang.newline();
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
                lang.quotes(this.endpoint) + ", " + 
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
            return ".wait(" + lang.renderTypes(this.wait.types) + ")" + lang.newline() +
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
        return "def " + this.endpoint + "(" + lang.renderArgs(this.want.names) + "):" + lang.newline();
    }
    // body: print WANT.names
    c.body = function() {
        return lang.tabs() + "print " + lang.renderArgs(this.want.names) + lang.newline();
    }
    // returnStr: return RETURNS
    c.returnStr = function() {
        if(this.returns === null) {
            return "";
        } else {
            return lang.tabs() + "return " + lang.renderArgs(this.returns) + lang.newline();
        }
    }

    this.coder = c;
}



exports.Python = Python;
