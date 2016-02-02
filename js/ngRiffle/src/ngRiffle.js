/* commonjs package manager support */
if (typeof module !== "undefined" && typeof exports !== "undefined" && module.exports === exports){
    var jsriffle = require('jsRiffle');
    module.exports = 'ngRiffle';
}

(function () {
    'use strict';


    var ngRiffleModule = angular.module('ngRiffle', []).provider('$riffle', $RiffleProvider);

    function $RiffleProvider() {

        var id = undefined;
        var providerAPIExcludes = ['Application', 'Domain', 'ModelObject', 'wait', 'want'];
        for(var key in jsRiffle){
          if(providerAPIExcludes.indexOf(key) === -1){
            this[key] = jsRiffle[key];
          }
        }

        this.SetDomain = function(domain){
          id = domain;
        };


        var interceptors = this.interceptors = [];

        this.$get = ["$rootScope", "$q", "$log", "$injector", function ($rootScope, $q, $log, $injector) {

            /**
             * Interceptors stored in reverse order. Inner interceptors before outer interceptors.
             */
            var reversedInterceptors = [];

            angular.forEach(interceptors, function (interceptor) {
                reversedInterceptors.unshift(
                    angular.isString(interceptor) ? $injector.get(interceptor) :  $injector.invoke(interceptor));
            });

            /**
             * @param func
             * @returns {Function}
             *
             * @description
             * Wraps a callback with a function that calls scope.$apply(), so that the callback is added to the digest
             */
            function digestWrapper(func) {

                return function () {
                    var cb = func.apply(this, arguments);
                    $rootScope.$apply();
                    return cb;
                };
            }

            var connection;
            var sessionDeferred = $q.defer();
            var sessionPromise = sessionDeferred.promise;
            
            var joinFnc = digestWrapper(function () {
                $rootScope.$broadcast("$riffle.open");
                sessionDeferred.resolve();
            });

            var leaveFnc = digestWrapper(function (reason, details) {
                $log.debug("Connection Closed: ", reason, details);
                sessionDeferred = $q.defer();
                sessionPromise = sessionDeferred.promise;
                $rootScope.$broadcast("$riffle.leave", {reason: reason, details: details});
            });


            connection = new DomainWrapper(jsRiffle.Domain(id));
            connection.want = jsRiffle.want;
            connection.wait = jsRiffle.wait;
            connection.ModelObject = jsRiffle.ModelObject;
            
            /**
             * Wraps WAMP actions, so that when they're called, the defined interceptors get called before the result is returned
             *
             * @param type
             * @param args
             * @param callback
             * @returns {*}
             */
            var interceptorWrapper = function (type, args, callback) {

                var result = function (result) {
                    return {result: result, type: type, args: args};
                };

                var error = function (error) {
                    $log.error("$riffle error", {type: type, arguments: args, error: error});
                    return $q.reject({error: error, type: type, args: args});
                };

                // Only execute the action callback once we have an established session
                var action = sessionPromise.then(function () {
                    return callback();
                });

                var chain = [result, error];

                // Apply interceptors
                angular.forEach(reversedInterceptors, function (interceptor) {
                    if (interceptor[type + 'Response'] || interceptor[type + 'ResponseError']) {
                        chain.push(interceptor[type + 'Response'], interceptor[type + 'ResponseError']);
                    }
                });

                // We only want to return the actually result or error, not the entire information object
                chain.push(
                    function (response) {
                        return response.result;
                    }, function (response) {
                        return $q.reject(response.error);
                    }
                );

                while (chain.length) {
                    var resolved = chain.shift();
                    var rejected = chain.shift();

                    action = action.then(resolved, rejected);
                }

                return action;
            };

            function DomainWrapper(riffleDomain){
              this.conn = riffleDomain;
              this.conn.onJoin = joinFnc;
              this.conn.onLeave = leaveFnc;
            }
            Domain.prototype.subdomains = {};
            Domain.prototype.join = function(){
              this.conn.Join();
            };
            Domain.prototype.leave = function(){
              this.conn.Leave();
            };
            Domain.prototype.subscribeOnScope = function(scope, channel, callback){
              var self = this;
              return this.subscribe(channel, callback).then(function(){
                scope.$on('$destroy', function () {
                  return self.unsubscribe(channel);
                });
              });
            };
            Domain.prototype.setToken = function(tok) {
                this.conn.SetToken(tok);
            };
            Domain.prototype.getToken = function() {
                return this.conn.GetToken();
            };
            Domain.prototype.unsubscribe = function (channel) {
              var self = this;
              return interceptorWrapper('unsubscribe', arguments, function () {
                return self.conn.Unsubscribe(channel);
              });
            };
            Domain.prototype.publish = function(){
              var a = arguments
              var self = this;
              return interceptorWrapper('publish', arguments, function(){
                return self.conn.Publish.apply(self.conn, a);
              });
            };
            Domain.prototype.register = function (action, handler) {
              if(typeof(handler) === 'function'){
                handler = digestWrapper(handler);
              }else{
                handler.fp = digestWrapper(handler.fp);
              }
              var self = this;
              return interceptorWrapper('register', arguments, function () {
                return self.conn.Register(action, handler);
              });
            };
            Domain.prototype.subscribe = function (action, handler) {
              if(typeof(handler) === 'function'){
                handler = digestWrapper(handler);
              }else{
                handler.fp = digestWrapper(handler.fp);
              }
              var self = this;
              return interceptorWrapper('subscribe', arguments, function () {
                return self.conn.Subscribe(action, handler);
              });
            };
            Domain.prototype.unregister = function (registration) {
              var self = this;
              return interceptorWrapper('unregister', arguments, function () {
                return self.conn.Unregister(registration);
              });
            };
            Domain.prototype.call = function () {
              var a = arguments
              var self = this;
              return interceptorWrapper('call', arguments, function () {
                return self.conn.Call.apply(self.conn, a);
              });
            };
            Domain.prototype.subdomain = function(id) {
              var tmp = new DomainWrapper(this.conn.Subdomain(id));
              this.subdomains[id] = tmp;
              return tmp;
            };
            Domain.prototype.linkDomain = function(id) {
              var tmp = new DomainWrapper(this.conn.LinkDomain(id));
              this.subdomains[id] = tmp;
              return tmp;
            };
            Domain.prototype.login = function() {
              var self = this;
              var username = arguments[0];
              if(!username){
                username = "_user";
              }
              function success(domain){
                var tmp = new DomainWrapper(domain);
                self.subdomains[username] = tmp;
                return tmp;
              }
              function error(err){
                return err;
              }
              return this.conn.Login.apply(this.conn, arguments).then(success, error);
            };
            Domain.prototype.registerAccount = function() {
              return this.conn.RegisterAccount.apply(this.conn, arguments);
            };
            //Need these for ModelObject compatability
            Domain.prototype.Call = Domain.prototype.call;
            Domain.prototype.LinkDomain = Domain.prototype.linkDomain;


            /**
             * Subscription object which self manages reconnections
             * @param topic
             * @param handler
             * @param options
             * @param subscribedCallback
             * @returns {{}}
             * @constructor
            var Subscription = function (topic, handler, options, subscribedCallback) {

                var subscription = {}, unregister, onOpen, deferred = $q.defer();

                handler = digestWrapper(handler);

                onOpen = function () {
                    var p = connection.session.subscribe(topic, handler, options).then(
                        function (s) {
                            if (subscription.hasOwnProperty('id')) {
                                delete subscription.id;
                            }

                            subscription = angular.extend(s, subscription);
                            deferred.resolve(subscription);
                            return s;
                        }
                    );
                    if (subscribedCallback) {
                        subscribedCallback(p);
                    }

                };

                if (connection.isOpen) {
                    onOpen();
                }

                unregister = $rootScope.$on("$riffle.open", onOpen);

                subscription.promise = deferred.promise;
                subscription.unsubscribe = function () {
                    unregister(); //Remove the event listener, so this object can get cleaned up by gc
                    return connection.session.unsubscribe(subscription);
                };

                return subscription.promise;
            };
             */


            return connection;
        }];

        return this;

    }
})();
