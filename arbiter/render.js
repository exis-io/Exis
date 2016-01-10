///////////////////////////////////////////////////////////////////////////////
//
//  Render
//  A helper package for Exis documentation and testing.
//
//  Copyright (C) 2015-2016 Exis
//
///////////////////////////////////////////////////////////////////////////////


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
}

Request.prototype = {
    /**
     * Perform some setup on the request object so we can render with
     * less work below (stuff like pull out the names and the types from
     * the want object, etc..)
     */
    setup: function(coder, lang) {
        this.lang = lang;
        coder.action = this.action;
        coder.endpoint = this.endpoint;
        coder.exceptions = this.exceptions;
        if(this.want !== null) {
            coder.want = this.pullNameTypes(this.want);
        }
        if(this.wait !== null) {
            coder.wait = this.pullNameTypes(this.wait);
        }
        if(this.returns !== null) {
            coder.returns = this.codeFormat(this.returns);
        }
        if(this.args !== null) {
            coder.args = this.codeFormat(this.args);
        }
    },
    /**
     * Create new copy of this exact object
     */
    copy: function() {
        var c = new Request();
        c.action = this.action;
        c.endpoint = this.endpoint;
        c.args = this.args;
        c.wait = this.wait;
        c.want = this.want;
        c.returns = this.returns;
        c.exceptions = this.exceptions;
        return c;
    },
    inherit: function(t) {
        for(var p in Request.prototype) {
            t[p] = Request.prototype[p];
        }
    },
    /**
     * Helper function to separate the names and types from want arrays
     * returns {names: <names list>, types: <types list>}
     */
    pullNameTypes: function(obj) {
        var names = [];
        var types = [];
        for(var i = 0; i < obj.length; i++) {
            var w = obj[i];
            var sp = w.split(":");
            types[types.length] = this.lang.properTypeStr(sp[0]);
            names[names.length] = sp[1];
        }
        var o = {};
        o.names = names;
        o.types = types;
        return o;
    },
    /**
     * Helper function to create an array of properly formatted code lists
     * Example: if you ask for ["Hi", 0] the string is "Hi, 0" when it should
     * actually be '"Hi", 0'.
     */
    codeFormat: function(obj) {
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
    },
    isPubCall: function() {
        if(this.action == "publish" || this.action == "call")
            return true;
        return false;
    },
    isRegSub: function() {
        if(this.action == "register" || this.action == "subscribe")
            return true;
        return false;
    },
    isPub: function() {
        return this.action == "publish";
    },
    isSub: function() {
        return this.action == "subscribe";
    },
    isReg: function() {
        return this.action == "register";
    },
    isCall: function() {
        return this.action == "call";
    }
};


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
