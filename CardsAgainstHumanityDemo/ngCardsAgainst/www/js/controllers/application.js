'use strict';

/**
 * @ngdoc function
 * @name cardsAgainst.controller:AppCtrl
 * @description
 * # AppCtrl
 * Controller of the cardsAgainst
 */
angular.module('cardsAgainst')
  .controller('AppCtrl',['$scope', '$wamp', '$http', function ($scope, $wamp, $http) {

    try{
      $wamp.close();
    }catch(e){
    }

    $scope.loggedin = false;
    $scope.session = null;
    $scope.username = null;

    var registrar = 'https://node.exis.io:8880/';

    $scope.login = function (username) {
      if(username){
        username = 'xs.demo.exis.cardsagainst.' + username;
      }
      var credentials = angular.toJson({domain: username, requestingdomain: "xs.demo.exis.cardsagainst"});
      attemptLogin();

      function register(){
        var registerURL = registrar + 'login';
        $http.post(registerURL, credentials).then(getToken, error);
      }

      function attemptLogin(){
        var loginURL = registrar + 'login';
        $http.post(loginURL, credentials).then(buildSession, register);
      }

      function getToken(ret){
        var loginURL = registrar + 'login';
        $http.post(loginURL, credentials).then(buildSession, error);
      }
    };

    function buildSession (result) {
      $scope.session = {
        domain: result.data.domain,
        token: result.data.login_token
      };
      connectWamp($scope.session);
    }

    function connectWamp(session){
      $scope.username = $scope.getName(session.domain);
      $wamp.connection._options.realm = session.domain;
      $wamp.connection._options.authmethods = ['token'];
      $wamp.connection._options.authid = session.domain;
      $wamp.connection._options.onchallenge = function(){return session.token;};
      $wamp.open();
    }

    function error(ret){
      console.log(ret);
    }

    $scope.$on('$wamp.open', function() {
      $scope.loggedIn = true;
    });

    $scope.$on('$wamp.close', function() {
      $scope.loggedin = false;
      $scope.session = null;
    });

    $scope.getName = function(domain){
      return domain.split('.')[domain.split('.').length - 1];
    };

  }]);
