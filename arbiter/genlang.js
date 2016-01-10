
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

/**
 * Generic language class with a bunch of functions
 * that might need to be overloaded depending on the lang chosen.
 */
function Language(lang) {
    lang.typeStringMap = {
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
    },
    quotes: function(obj) {
        return '"' + obj + '"';
    },
    newline: function(num) {
        return "\n";
    },
    tabs: function(num) {
        return "    ";
    },
    capitalize: function(s) {
        return s.charAt(0).toUpperCase() + s.slice(1);
    }
};

exports.Language = Language;
exports.Coder = Coder;
