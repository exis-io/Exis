'use strict';

/**
 * @ngdoc function
 * @name cardsAgainst.controller:RoomCtrl
 * @description
 * # RoomCtrl
 * Controller of the cardsAgainst
 */
angular.module('cardsAgainst')
  .controller('RoomCtrl',['$scope', '$wamp', '$state', function ($scope, $wamp, $state) {
    $scope.$on('$ionicView.enter', function(e) {

      if(!$scope.loggedIn){
        $state.go('home');
        return;
      }

      /*JOIN/LEAVE/PLAY LOGIC*/
      
      var container = 'xs.demo.exis.cardsagainst.Osxcontainer.gamelogic';
      var roomId = '';
      var drawReg = null;
      var alreadyPicked = false;

      $wamp.call(container + '/play',[]).then(startGame, error);
      function startGame(ret){
        $scope.cards = ret.args[0];
        $scope.players = ret.args[1];
        $scope.state = ret.args[2];
        roomId = ret.args[3];
        registerAndSubscribe();
      }

      function registerAndSubscribe(){
        $wamp.call('xs.demo.Bouncer/setPerm', [container, $scope.session.domain + '/draw']).then(success, error);
        drawReg = $wamp.register($scope.session.domain + '/draw', addNewCard);
        $wamp.subscribeOnScope($scope, container + roomId + '/answering', answerPhase);
        $wamp.subscribeOnScope($scope, container + roomId + '/picking', pickPhase);
        $wamp.subscribeOnScope($scope, container + roomId + '/scoring', scorePhase);
        $wamp.subscribeOnScope($scope, container + roomId + '/joined', playerJoined);
        $wamp.subscribeOnScope($scope, container + roomId + '/left', playerLeft);
      }

      $scope.leave = function(){
        $wamp.call(container + roomId + '/leave',[]).then(success, error);
        drawReg.$$state.value.unregister();
        $state.go('home');
      };

      $scope.pick = function(card){
        if(pickAllowed()){
          $wamp.call(container + roomId + '/pick', [card]).then(success, error);
          $scope.selected = card;
          alreadyPicked = true;
        }
      };

      /*HANDLERS FOR SUBS AND REGISTERED CALLS*/

      function answerPhase(ret){
        alreadyPicked = false;
        $scope.selected = '';
        $scope.state = 'Answering';
        $scope.question = ret[1];
        for(var player in $scope.players){
          if(ret[0].domain === $scope.players[player].domain){
            $scope.players[player].czar = ret[0].czar;
          }else{
            $scope.players[player].czar = false;
          }
        }
      }

      function pickPhase(ret){
        alreadyPicked = false;
        $scope.selected = '';
        $scope.state = 'Picking';
        $scope.pickedCards = ret[0];
        for(var card in $scope.pickedCards){
          var index = $scope.cards.indexOf($scope.pickedCards[card]);
          if(index > -1){
            $scope.cards.splice(index, 1);
          }
        }
      }

      function scorePhase(ret){
        $scope.state = 'Scoring';
        $scope.chosenCard = ret[1];
        $scope.winner = $scope.getName(ret[0].domain);
        for(var player in $scope.players){
          if(ret[0].domain === $scope.players[player].domain){
            $scope.players[player].score = ret[0].score;
          }
        }
      }

      function addNewCard(card){
        $scope.cards.push(card[0][0]);
      }

      function playerJoined(player){
        $scope.players.push(player[0]);
      }

      function playerLeft(player){
        $scope.players.splice($scope.players.indexOf(getPlayer(player[0].domain)), 1);
      }
        
      /*HELPER FUNCTIONS FOR VIEW/LOGICAL EASE*/

      $scope.getCzar = function(){
        for(var i in $scope.players){
          if($scope.players[i].czar){
            return $scope.getName($scope.players[i].domain);
          }
        }
      };

      $scope.amCzar = function(){
        return $scope.getCzar() === $scope.getName($scope.session.domain)
      };

      function pickAllowed(){
        var czar = $scope.amCzar();
        if($scope.state === 'Answering'){
          return !czar && !alreadyPicked;
        }else if($scope.state === 'Picking'){
          return czar && !alreadyPicked;
        }
      }

      function getPlayer(domain){
        for(var i in $scope.players){
          if($scope.players[i].domain === domain){
            return $scope.players[i];
          }
        }
      }

      function success(ret){
        console.log(ret);
      }

      function error(ret){
        console.log(ret);
      }
    });
  }]);
