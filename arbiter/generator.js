///////////////////////////////////////////////////////////////////////////////
//
//  Generator
//  A helper package for Exis documentation and testing.
//
//  Copyright (C) 2015-2016 Exis
//
///////////////////////////////////////////////////////////////////////////////

var render = require("./render");
var Python = require("./genpy").Python;
var JS = require("./genjs").JS;

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



// If running in nodejs then read in what they want us to do:
if(require.main === module) {
    var req = new render.Request();
    
    var lang = null;
    // Run through args, they define what they want to assign
    for(var i = 2; i < process.argv.length; i++) {
        var a = process.argv[i];
        var sp = a.split('=');
        var k = sp[0];
        var v = sp[1];
        if(k == "lang") {
            if(v == "python")
                lang = Python;
            else if(v == "js")
                lang = JS;
            else
                console.log('!! Unsupported language requested');
        } else if(k == "-?") {
            console.log('Usage: generator.js key=value... to define a Request object');
            console.log('  Valid keys:');
            console.log('    lang=python|js|swift|go');
            console.log('    action=register|call|publish|subscribe');
            console.log('    endpoint=endPoint');
            console.log('    want=JSON');
            console.log('    wait=JSON');
            console.log('    returns=JSON');
            console.log('    args=JSON');
            console.log('');
            console.log('  JSON objects for want and wait look like ["type:name"] ie. ["str:s"]');
            process.exit();
        } else {
            req.addRequirement(k, v);
        }
    }

    if(lang !== null) {
        var l = new lang(req);
        console.log(l.generate());
    }
}

