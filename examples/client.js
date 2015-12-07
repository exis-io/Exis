var riffle = require('jsriffle');
// riffle.setDevFabric();

// var app = new riffle.Domain("xs.demo");
// var me = app.subdomain("client");
// var server = app.subdomain("server");


// me.onJoin = function() {
//     console.log("Domain " + this.domain + " joined");

//     server.publish('sub', 'Hello,', 'You scallywag!');

//     server.call('register', "Ping, ", "she wrote").then(
//       function (res) {
//          console.log("Call returned: ", res);
//       }
//    );
// };


// me.join();


var domain = riffle.Domain("xs.damouse.js.beta")

domain.Join()

domain.Publish("xs.damouse.js.alpha/sub")
