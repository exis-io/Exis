

require('./polyfill.js');

var log = require('./log.js');
var pjson = require('../package.json');
var when = require('when');
var fn = require("when/function");
var configure = require('./configure.js');

exports.version = pjson.version;
exports.transports = configure.transports;
exports.when = when;
exports.log = log;


//
// Begin GOJS implementation
//

var go = require('./go.js');
var ws = require('./transport/websocket.js');


// External websocket implementation, for now
// Dont need any of this-- just return the conn
var Ws = function () {
    this.open = function(url) {
        // Methods available on the conn: console.log, protocol, send, close, onmessage, onopen, onclose, info
        var factory = new ws.Factory({'type': 'websocket', 'url': url});
        this.conn = factory.create();
        this.conn.onmessage = this.onmessage;
        this.conn.onopen = this.onopen;
        this.conn.onclose = this.onclose;
    }
}; 

global.WsWrapper = new Ws();

// console.log(global.Domain.Hello);
var domain = global.MantleDomain.New("xs.damouse");
var subdomain = domain.Subdomain("alpha");

domain.Join()

//console.log(domain);
//console.log(subdomain);


/*
global.Wrapper.New();

// Create and open the connection, let the wrapper have it 
var conn = new Ws();
conn.open()

global.Wrapper.SetConnection(conn);

//
// Start client implementation
//

function prependDomain(domain, target) {
    if (target.indexOf("xs.") > -1) {
        return target
    }

    return domain + "/" + target;
};

function flattenHash(hash) {
    var ret = [];

    for (k in hash) {
        ret.push(hash[k]);
    }

    return ret
}


exports.Domain = global.Domain.New;

// Old domain implementation 


// Introduction of domain object. Wraps one connection and offers multiple levels of 
// indirection for interacting with remote domains
var Domain = function (name) {
    this.domain = name;
    this.connection = null;
    this.session = null;
    this.pool = [this];
    this.joined = false;
}; 

// Does not check the validity of the incoming or final name
Domain.prototype.subdomain = function(name) {
   var child = new Domain(this.domain + '.' + name)

   // If already connected instantly trigger the domain's handler
   if (this.joined) {
        child.connection = this.connection;
        child.session = this.session
        child.joined = true;
        child.onJoin();
   }

   this.pool.push(child);
   child.pool = this.pool;

   return child;
};



Domain.prototype.join = function() {
   var self = this;
   self.connection = new riffle.Connection(self.domain);

    self.connection.onJoin = function (session) {
        self.session = session;

        for (var i = 0; i < self.pool.length; i++)  {
            self.pool[i].session = session; 
            self.pool[i].connection = this.connection;
        }

        for (var i = 0; i < self.pool.length; i++)  {
            if (!self.pool[i].joined) {
                self.pool[i].joined = true;
                self.pool[i].onJoin();
            }
        }
   };

   self.connection.join();
};

Domain.prototype.leave = function() {
    // Not done!
    // this.session.close();
};

Domain.prototype.onJoin = function() {
    log.debug("Domain " + this.domain + " default join");
};

Domain.prototype.onLeave = function() {
    log.debug("Domain " + this.domain + " default leave");
};


// Message patterns
Domain.prototype.subscribe = function(action, handler) {
    return this.session.subscribe(prependDomain(this.domain, action), handler);
};

Domain.prototype.register = function(action, handler) {
    return this.session.register(prependDomain(this.domain, action), handler);
};

Domain.prototype.call = function() {
    var args = flattenHash(arguments);
    var action = args.shift();
    
    return this.session.call(prependDomain(this.domain, action), args);
};

Domain.prototype.publish = function() {
    var args = flattenHash(arguments);
    var action = args.shift();

    return this.session.publish(prependDomain(this.domain, action), args);
};

Domain.prototype.unsubscribe = function(action) {
   
};

Domain.prototype.unregister = function(action) {

};
*/