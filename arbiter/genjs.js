///////////////////////////////////////////////////////////////////////////////
//
//  GenJS
//  A helper package for Exis documentation and testing.
//
//  Copyright (C) 2015-2016 Exis
//
///////////////////////////////////////////////////////////////////////////////

var r = require('./genlang');
var Language = r.Language;
var Coder = r.Coder;

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
        //return this.commentBefore() + this.exisLine() + lang.newline() + this.commentAfter();
        return this.exisLine();
    }
    // commentBefore: // comment
    c.commentBefore = function() {
        return "// " + this.comment();
    }
    c.comment = function() {
        // TODO need to get it to print out str not String here
        return "Example Template " + this.endpoint + " " + lang.req.want.types + " " + this.returns + lang.newline();
    }
    // commentAfter: // End comment
    c.commentAfter = function() {
        return "// End " + this.comment();
    }
    // exisLine: this.ACTION(ENDPOINT, exisArgs) afterExis;
    c.exisLine = function() {
        return lang.getActionVar() + "." + lang.capitalize(this.action) + "(" + 
            lang.quotes(this.endpoint) + ", " + this.exisArgs() + ")" + this.afterExis() + ";";
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
        return "riffle.want(function (" + lang.renderArgs(this.want.names) + ") {" + lang.newline() + 
            this.body() + "}, " + lang.renderTypes(this.want.types) + ")";
    }
    // body: console.log(WANT.names); \n returnStr
    c.body = function() {
        return lang.tabs() + "console.log(" + lang.renderArgs(this.want.names) + ");" + lang.newline() +
            this.returnStr();
    }
    // returnStr: return RETURNS;
    c.returnStr = function() {
        if(this.returns !== null) {
            return lang.tabs() + "return " + lang.renderArgs(this.returns) + ";" + lang.newline();
        } else {
            return "";
        }
    }
    // afterExis: .then(riffle.wait(function(WAIT.names) { console.log(WAIT.names); }, WAIT.types, afterExisErr
    c.afterExis = function() {
        if(this.isCall()) {
            return ".then(riffle.wait(function(" + lang.renderArgs(this.wait.names) + ") {" + lang.newline() +
                    lang.tabs() + "console.log(" + lang.renderArgs(this.wait.names) + ");" + lang.newline() +
                    "}, " + lang.renderTypes(this.wait.types) + "), " + this.afterExisErr() + ")";
        } else {
            return "";
        }
    }
    c.afterExisErr = function() {
        return "function(err) {" + lang.newline() +
                lang.tabs() + 'console.log("ERROR: " + err);' + lang.newline() + "}";
    }

    this.coder = c;
}

exports.JS = JS;
