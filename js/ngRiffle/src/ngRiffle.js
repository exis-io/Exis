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
                connection.connected = true;
                sessionDeferred.resolve();
            });

            var leaveFnc = digestWrapper(function (reason, details) {
                //$log.debug("Connection Closed: ", reason, details);
                connection.connected = false;
                sessionDeferred = $q.defer();
                sessionPromise = sessionDeferred.promise;
                $rootScope.$broadcast("$riffle.leave", {reason: reason, details: details});
            });


            connection = new DomainWrapper(jsRiffle.Domain(id));
            connection.want = jsRiffle.want;
            connection.wait = jsRiffle.wait;
            connection.ModelObject = jsRiffle.ModelObject;
            connection.connected = false;

            
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
                    //$log.error("$riffle error", {type: type, arguments: args, error: error});
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
            DomainWrapper.prototype.join = function(){
              return this.conn.join();
            };
            DomainWrapper.prototype.leave = function(){
              return this.conn.leave();
            };
            DomainWrapper.prototype.subscribeOnScope = function(scope, channel, callback){
              var self = this;
              return this.subscribe(channel, callback).then(function(){
                scope.$on('$destroy', function () {
                  return self.unsubscribe(channel);
                });
              });
            };
            DomainWrapper.prototype.setToken = function(tok) {
                this.conn.setToken(tok);
            };
            DomainWrapper.prototype.getToken = function() {
                return this.conn.getToken();
            };
            DomainWrapper.prototype.unsubscribe = function (channel) {
              var self = this;
              return interceptorWrapper('unsubscribe', arguments, function () {
                return self.conn.unsubscribe(channel);
              });
            };
            DomainWrapper.prototype.publish = function(){
              var a = arguments
              var self = this;
              return interceptorWrapper('publish', arguments, function(){
                return self.conn.publish.apply(self.conn, a);
              });
            };
            DomainWrapper.prototype.register = function (action, handler) {
              if(typeof(handler) === 'function'){
                handler = digestWrapper(handler);
              }else{
                handler.fp = digestWrapper(handler.fp);
              }
              var self = this;
              return interceptorWrapper('register', arguments, function () {
                return self.conn.register(action, handler);
              });
            };
            DomainWrapper.prototype.subscribe = function (action, handler) {
              if(typeof(handler) === 'function'){
                handler = digestWrapper(handler);
              }else{
                handler.fp = digestWrapper(handler.fp);
              }
              var self = this;
              return interceptorWrapper('subscribe', arguments, function () {
                return self.conn.subscribe(action, handler);
              });
            };
            DomainWrapper.prototype.unregister = function (registration) {
              var self = this;
              return interceptorWrapper('unregister', arguments, function () {
                return self.conn.unregister(registration);
              });
            };
            DomainWrapper.prototype.call = function () {
              var a = arguments
              var self = this;
              var callDeferred = $q.defer();
              //
              //for now we need to splat the args because the core returns them in a list
              function splat(args){
                callDeferred.resolve.apply(callDeferred, args);
              }
              interceptorWrapper('call', arguments, function () {
                return self.conn.call.apply(self.conn, a);
              }).then(splat, callDeferred.reject);
              return callDeferred.promise;
            };
            DomainWrapper.prototype.subdomain = function(id) {
              return new DomainWrapper(this.conn.subdomain(id));
            };
            DomainWrapper.prototype.linkDomain = function(id) {
              return new DomainWrapper(this.conn.linkDomain(id));
            };
            DomainWrapper.prototype.login = function(user) {
              var self = this;
              //deferred for knowing when process is done
              var userDeferred = $q.defer();

              var args = [];
              if(user && user.username){
                args.push(user.username);
              }
              //figure out auth level from user object
              var auth0 = false;
              if(!user || !user.password || user.password === ""){
                auth0 = true;
              }else{
                args.push(user.password);
              }

              
              function resolve(){
                userDeferred.resolve(connection.User);
              }

              //if we are auth1 load user data
              function load(){
                connection.User.load().then(userDeferred.resolve, userDeferred.reject);
              }

              //if we get success from the registrar on login continue depending on auth level
              function success(domain){
                if(auth0){
                  //if auth0 then we don't have user storage
                  connection.User = new DomainWrapper(domain); 
                  connection.User.join();
                  sessionPromise.then(resolve);
                }else{
                  //if auth1 use User class to wrap domain and implement user storage and load user data
                  connection.User = new User(self, domain); 
                  connection.User.join();
                  sessionPromise.then(load);
                }
              }

              //attempt registration login and continue process on success
              this.conn.login.apply(this.conn, args).then(success, userDeferred.reject);

              //return the promise which will be resolved once the login process completes.
              return userDeferred.promise;
            };
            DomainWrapper.prototype.registerAccount = function(user) {
              return this.conn.registerAccount(user.username, user.password, user.email, user.name);
            };

            function User(app, domain) {
              DomainWrapper.call(this, domain);
              this.storage = app.subdomain("Auth");
            }
            User.prototype = Object.create(DomainWrapper.prototype);
            User.prototype.constructor = User;
            User.prototype.email = "";
            User.prototype.name = "";
            User.prototype.privateStorage = {};
            User.prototype.publicStorage = {};
            User.prototype.save = function(){
              return this.storage.call('save_user_data', this.publicStorage, this.privateStorage);
            };
            User.prototype.load = function(){
              var self = this;
              var loadDeferred = $q.defer();
              function loadUser(user){
                self.name = user.name;
                self.email = user.email;
                self.gravatar = user.gravatar;
                self.privateStorage = user.private || {};
                self.publicStorage = user.public || {};
                loadDeferred.resolve(self);
              }
              function error(error){
                loadDeferred.reject(error);
              }
              this.storage.call('get_user_data').then(loadUser, error);
              return loadDeferred.promise;
            };
            User.prototype.getPublicData = function(query){
              return this.storage.call('get_public_data', query)
            };



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
