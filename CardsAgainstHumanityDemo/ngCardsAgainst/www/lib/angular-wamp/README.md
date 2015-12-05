
# AngularWAMP

AngularWAMP is an AngularJS wrapper for [AutobahnJS](https://github.com/tavendo/AutobahnJS) (v 0.9.5) for WAMP v2 (Web Application Messaging Protocol).

It simplifies getting WAMP v2 integrated into your AngularJS application.  For the most part, it's works just like AutobahnJS, with a couple of angular related changes, which are noted below.

###What is this library used for?
This library allows you to use WebSockets in your AngularJS app with any language that support the WAMPv2 protocol.  This includes, [Python](https://github.com/crossbario/crossbar) and [PHP](https://github.com/voryx/Thruway).  For a complete list of WAMPv2 implementations, visit the [implementations page](http://wamp.ws/implementations/) on wamp.ws.

For more information on why WAMP is a great choice for your project, read: [Why WAMP?](http://wamp.ws/why/)

## Installing AngularWAMP

#### With Bower
You can [download](https://github.com/voryx/angular-wamp/archive/master.zip) the zip file or install AngularWAMP via [Bower](http://bower.io/#install-bower):

```bash
$ bower install angular-wamp --save
```

To use AngularWAMP in your project, you need to include the following files in your HTML:

```html
<!-- AngularJS -->
<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.2.26/angular.min.js"></script>

<!-- AutobahnJS -->
<script src="bower_components/autobahn/autobahn.js"></script>

<!-- AngularWAMP -->
<script src="bower_components/angular-wamp/release/angular-wamp.js"></script>
```

#### With NPM

```bash
$ npm install angular-wamp
```

And then you can import angular-wamp into your js files:

```js
import angular     from 'angular';
import angularWamp from 'angular-wamp';

// module definition
export default angular.module('app.starter', [angularWamp])
    .config(function($wampProvider) {
        $wampProvider.init({
            url: 'ws://127.0.0.1:9000/',
            realm: 'realm1'
            //Any other AutobahnJS options
        });
    })
    .run(function($wamp){
        $wamp.open();
    });

angular.bootstrap(document, ['app.starter']);

```

## Documentation

### Configuration

Before you can use AngularWAMP, you have to inject the 'vxWamp' module into your application.

```Javascript
var app = angular.module("myApp", ["vxWamp"]);
```

Then configure the connection settings, by passing an options object to ``$wampProvider.init()``.

```Javascript
app.config(function ($wampProvider) {
     $wampProvider.init({
        url: 'ws://127.0.0.1:9000/',
        realm: 'realm1'
        //Any other AutobahnJS options
     });
 })
```

Now the $wamp service is available to be injected into any controller, service or factory.

```Javascript
app.controller("MyCtrl", function($scope, $wamp) {

   // 1) subscribe to a topic
   function onevent(args) {
      $scope.hello = args[0];
   }
   $wamp.subscribe('com.myapp.hello', onevent);

   // 2) publish an event
   $wamp.publish('com.myapp.hello', ['Hello, world!']);

   // 3) register a procedure for remoting
   function add2(args) {
      return args[0] + args[1];
   }
   $wamp.register('com.myapp.add2', add2);

   // 4) call a remote procedure
   $wamp.call('com.myapp.add2', [2, 3]).then(
      function (res) {
         $scope.add2 = res;
   });      
});
```

You'll notice that we did not need to wait for the connection to be established before making WAMP calls.  That's because, all requests are queued until a connection is established.

###Connecting

To open the connection you just need to call ``$wamp.open()``.  This can be done from anywhere that allows ``$wamp`` to be injected.  If you want to open the connection right when the app starts, you can add it to ``.run()``.

```Javascript
    .run(function($wamp){
        $wamp.open();
    })
```

### Events
One area that AngularWAMP differs from AutobahnJS, is in how ``onclose`` and ``onopen`` are handled.  In AngularWAMP, they're events that are emitted globally.  This has the added benefit of allowing the entire app be aware of the connection state.

```Javascript
app.controller("MainCtrl", function($scope, $wamp) {
    $scope.$on("$wamp.open", function (event, session) {
        console.log('We are connected to the WAMP Router!'); 
    });
    
    $scope.$on("$wamp.close", function (event, data) {
        $scope.reason = data.reason;
        $scope.details = data.details;
    });
            
});
```

###Authentication
The other major change from AutobahnJS is authentication.  The auth methods can be added to the connection options through the ``$wampProvider`` within ``.config()``.

```Javascript
app.config(function ($wampProvider) {
     $wampProvider.init({
        url: 'ws://127.0.0.1:9000/',
        realm: 'realm1'
        authmethods: ["myauth"]
     });
 })
```

If the router sends a Challenge Message, it gets emitted with the event ``$wamp.onchallange`` that has to return a promise. 

note: This will probably change in the future, if I can figure out a better way to do this.

```Javascript
$scope.$on("$wamp.onchallenge", function (event, data) {
    if (data.method === "myauth"){                
        return data.promise.resolve(autobahn.auth_cra.sign('someSecret', data.extra.challenge));
     } 
     //You can also access the following objects:
     // data.session             
     //data.extra
});
```

###Other Properties

You can also access the ``connection`` and ``session`` through the ``$wamp`` service:

```Javascript
$wamp.session;
$wamp.connection;
```

###Interceptors

AngularWAMP supports [$http style interceptors](https://docs.angularjs.org/api/ng/service/$http#interceptors)

The interceptors are service factories that are registered with the $wampProvider by adding them to the $wampProvider.interceptors array. The factory is called and injected with dependencies (if specified) and returns the interceptor.

At the moment only response interceptors are supported.  There are two interceptors for each WAMP action.  They're made up of the action name followed by `Response` or `ResponseError` for errors.

```JS
.factory('myWampInterceptor', function ($q) {


        return {

            // optional method
            'callResponse': function (response) {
                // do something on success
                return response;
            },

            // optional method
            'callResponseError': function (response) {
                // do something on error
                return response
            },

            // optional method
            'subscribeResponse': function (response) {

                //Mangle up the subscription response callback
                var r = response.result.handler;
                response.result.handler = function (args) {
                    args[0].name = "Mickey Mouse";
                    return r(args);
                };

                //You can also return a promise
                return $q.when(response);
            },

            // optional method
            'subscribeResponseError': function (response) {
                // do something on error
                return response;
            },
            // optional method
            'publishResponse': function (response) {
                // do something on success
                return response;
            },

            // optional method
            'publishResponseError': function (response) {
                // do something on error
                return response
            },
            // optional method
            'registerResponse': function (response) {
                // do something on success
                return response;
            },

            // optional method
            'registerResponseError': function (response) {
                // do something on error
                return response
            },
        };
    });



    $wampProvider.interceptors.push('myWampInterceptor');
    
```

For more information, you can reference the AutobahnJS [documentation](http://autobahn.ws/js/reference.html).
