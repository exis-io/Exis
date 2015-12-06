var riffle = require('jsriffle');
riffle.setDevFabric();

// var app = new riffle.Domain("xs.demo");
// var ng = app.subdomain("angular");
// var me = app.subdomain("server");


// me.onJoin = function() {
//     console.log("Domain " + this.domain + " joined");

//     this.subscribe('sub', function (args) {
//         console.log("Publish received:", args[0], args[1]);
//         //ng.publish('sub', "Server pubs, ", "Bye");
//     });

//     this.register('register', function(args) {
//         console.log("Call received: ",  args[0], args[1]);
//         //ng.call('register', "Server says, ", "hi");
//         return "Pong"
//     });
// };

// me.join();

riffle.HelloWorld("JS CLIENT: This function is called from the client library")