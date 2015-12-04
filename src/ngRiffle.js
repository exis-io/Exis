/* commonjs package manager support */
if (typeof module !== "undefined" && typeof exports !== "undefined" && module.exports === exports){
    var jsriffle = require('jsriffle');
    module.exports = 'ngRiffle';
}

(function () {
    'use strict';

    jsRiffle.setDevFabric();

    var ngRiffleModule = angular.module('ngRiffle', []).provider('$riffle', $RiffleProvider);

    function $RiffleProvider() {
        var options;

        this.init = function (initOptions) {
            options = initOptions || {};
        };


        var interceptors = this.interceptors = [];

        this.$get = ["$rootScope", "$q", "$log", "$injector", function ($rootScope, $q, $log, $injector) {

            var connection;
            var sessionDeferred = $q.defer();
            var sessionPromise = sessionDeferred.promise;

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

                // if (options.disable_digest && options.disable_digest === true) {
                //     return func;
                // }

                return function () {
                    var cb = func.apply(this, arguments);
                    $rootScope.$apply();
                    return cb;
                };
            }

            // options = angular.extend({onchallenge: digestWrapper(onchallenge), use_deferred: $q.defer}, options);

            connection = new jsRiffle.Domain(options);

            connection.onJoin = digestWrapper(function () {
                $rootScope.$broadcast("$riffle.open");
                sessionDeferred.resolve();
            });

            connection.onLeave = digestWrapper(function (reason, details) {
                $log.debug("Connection Closed: ", reason, details);
                sessionDeferred = $q.defer();
                sessionPromise = sessionDeferred.promise;
                $rootScope.$broadcast("$riffle.close", {reason: reason, details: details});
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

                unregister = $rootScope.$on("$riffle.open", onOpen);

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

            return {
                connection: connection,
                open: function () {
                    connection.join();
                },
                // TODO
                leave: function () {
                    connection.leave();
                },
                // TODO
                // subscribe: function (topic, handler, options, subscribedCallback) {
                //     return interceptorWrapper('subscribe', arguments, function () {
                //         return Subscription(topic, handler, options, subscribedCallback);
                //     });
                // },
                // TODO
                subscribeOnScope: function (scope, channel, callback) {
                    return this.subscribe(channel, callback).then(function (subscription) {
                        scope.$on('$destroy', function () {
                            return subscription.unsubscribe();
                        });
                    });
                },
                // TODO
                unsubscribe: function (subscription) {
                    return interceptorWrapper('unsubscribe', arguments, function () {
                        return subscription.unsubscribe();
                    });
                },
                publish: function () {
                    var a = arguments

                    return interceptorWrapper('publish', arguments, function () {
                        return connection.publish.apply(connection, a);
                    });
                },
                register: function (action, handler) {
                    handler = digestWrapper(handler);

                    return interceptorWrapper('register', arguments, function () {
                        return connection.register(action, handler);
                    });
                },
                subscribe: function (action, handler) {
                    handler = digestWrapper(handler);

                    return interceptorWrapper('subscribe', arguments, function () {
                        return connection.subscribe(action, handler);
                    });
                },
                // TODO
                unregister: function (registration) {
                    return interceptorWrapper('unregister', arguments, function () {
                        return registration.unregister();
                    });
                },
                call: function () {
                    var a = arguments

                    return interceptorWrapper('call', arguments, function () {
                        return connection.call.apply(connection, a);
                    });
                }
            };
        }];

        return this;

    }
})();