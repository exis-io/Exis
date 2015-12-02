var riffle = require('jsriffle');
riffle.setDevFabric();
console.log("Starting server")

function subscriptionHandler(args) {
    console.log("Publish received:", args[0]);
};

function registerHandler(args) {
    console.log("Call received: ",  args[0]);
    return "Pong"
};

var domain = new riffle.Domain("xs.demo");

domain.onJoin = function() {
    console.log("Domain " + this.domain + " joined with name " + this.name);

    this.subscribe('sub', subscriptionHandler).then(
        function (registration) {
            console.log("Subscription registered:", registration.id);
        },
        function (error) {
            console.log("Subscription failed:", error);
        }
    );

    this.register('register', registerHandler).then(
        function (registration) {
            console.log("Procedure registered:", registration.id);
        },
        function (error) {
            console.log("Registration failed:", error);
        }
    );
};

domain.join();
