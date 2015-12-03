/* commonjs package manager support */
if (typeof module !== "undefined" && typeof exports !== "undefined" && module.exports === exports){
    var autobahn = require('autobahn');
    var jsriffle = require('jsriffle');
    module.exports = 'vxWamp';
}

(function () {
    'use strict';

    var vxWampModule = angular.module('vxWamp', []).provider('$wamp', $WampProvider);

    function $WampProvider() {
        var options;

        this.init = function (initOptions) {
            console.log("Access");
            options = initOptions || {};
        };


        var interceptors = this.interceptors = [];

        this.$get = ["$rootScope", "$q", "$log", "$injector", function ($rootScope, $q, $log, $injector) {


            var connection;
            var sessionDeferred = $q.defer();
            var sessionPromise = sessionDeferred.promise;

            /**
             * @param session
             * @param method
             * @param extra
             * @returns {*}
             *
             * @description
             * Gets called when a Challenge Message is sent by the router
             */
            var onchallenge = function (session, method, extra) {

                var onChallengeDeferred = $q.defer();

                $rootScope.$broadcast("$wamp.onchallenge", {
                    promise: onChallengeDeferred,
                    session: session,
                    method: method,
                    extra: extra
                });

                return onChallengeDeferred.promise;
            };

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

                if (options.disable_digest && options.disable_digest === true) {
                    return func;
                }

                return function () {
                    var cb = func.apply(this, arguments);
                    $rootScope.$apply();
                    return cb;
                };
            }

            options = angular.extend({onchallenge: digestWrapper(onchallenge), use_deferred: $q.defer}, options);

            connection = new autobahn.Connection(options);
            connection.onopen = digestWrapper(function (session, details) {
                $log.debug("Congrats!  You're connected to the WAMP server!");
                $rootScope.$broadcast("$wamp.open", {session: session, details: details});
                sessionDeferred.resolve();
            });

            connection.onclose = digestWrapper(function (reason, details) {
                $log.debug("Connection Closed: ", reason, details);
                sessionDeferred = $q.defer();
                sessionPromise = sessionDeferred.promise;
                $rootScope.$broadcast("$wamp.close", {reason: reason, details: details});
            });


            /**
             * Subscription object which self manages reconnections
             * @param topic
             * @param handler
             * @param options
             * @param subscribedCallback
             * @returns {{}}
             * @constructor
             */
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

                unregister = $rootScope.$on("$wamp.open", onOpen);

                subscription.promise = deferred.promise;
                subscription.unsubscribe = function () {
                    unregister(); //Remove the event listener, so this object can get cleaned up by gc
                    return connection.session.unsubscribe(subscription);
                };

                return subscription.promise;
            };

            /**
             * Wraps WAMP actions, so that when they're called, the defined interceptors get called before the result is returned
             *
             * @param type
             * @param args
             * @param callback
             * @returns {*}
             */
            var interceptorWrapper = function (type, args, callback) {

                /**
                 * Default result
                 *
                 * @param result
                 * @returns {{result: *, type: *, args: *}}
                 */
                var result = function (result) {
                    return {result: result, type: type, args: args};
                };

                /**
                 * Default Error
                 *
                 * @param error
                 * @returns {{error: *, type: *, args: *}}
                 */
                var error = function (error) {
                    $log.error("$wamp error", {type: type, arguments: args, error: error});
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

            return {
                connection: connection,
                open: function () {
                    //If using WAMP CRA we need to get the authid before the connection can be opened.
                    if (options.authmethods && options.authmethods.indexOf('wampcra') !== -1 && !options.authid) {
                        $log.debug("You're using WAMP CRA.  The authid must be set on $wamp before the connection can be opened, ie: $wamp.setAuthId('john.doe')");
                    } else {
                        connection.open();
                    }
                },
                setAuthId: function (authid, open) {
                    options.authid = authid;
                    if (open) {
                        connection.open();
                    }
                },
                close: function () {
                    connection.close();
                },
                subscribe: function (topic, handler, options, subscribedCallback) {
                    return interceptorWrapper('subscribe', arguments, function () {
                        return Subscription(topic, handler, options, subscribedCallback);
                    });
                },
                subscribeOnScope: function (scope, channel, callback) {
                    return this.subscribe(channel, callback).then(function (subscription) {
                        scope.$on('$destroy', function () {
                            return subscription.unsubscribe();
                        });
                    });
                },
                unsubscribe: function (subscription) {
                    return interceptorWrapper('unsubscribe', arguments, function () {
                        return subscription.unsubscribe();
                    });
                },
                publish: function (topic, args, kwargs, options) {
                    return interceptorWrapper('publish', arguments, function () {
                        return connection.session.publish(topic, args, kwargs, options);
                    });
                },
                register: function (procedure, endpoint, options) {
                    endpoint = digestWrapper(endpoint);

                    return interceptorWrapper('register', arguments, function () {
                        return connection.session.register(procedure, endpoint, options);
                    });
                },
                unregister: function (registration) {
                    return interceptorWrapper('unregister', arguments, function () {
                        return registration.unregister();
                    });
                },
                call: function (procedure, args, kwargs, options) {
                    return interceptorWrapper('call', arguments, function () {
                        return connection.session.call(procedure, args, kwargs, options);
                    });
                },
                hello: function () {
                    console.log(jsriffle.biddle);
                    return interceptorWrapper('call', arguments, function () {
                        return connection.session.call(procedure, args, kwargs, options);
                    });
                }
            };
        }];

        return this;

    }
})();