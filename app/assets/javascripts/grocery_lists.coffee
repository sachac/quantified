class GroceriesController
  constructor: ($scope, $http, Auth, $interval) ->
    $scope.listID = document.getElementById('app').getAttribute('data-grocery-list-id');
    $scope.quickAdd = () ->
      $http.post('/grocery_lists/' + $scope.listID + '/quick_add.json', { quick_add: $scope.addText }).then (result) ->
        $scope.loadData();
        $scope.addText = ''
    $scope.loadData = () ->
      $http.get('/grocery_lists/' + $scope.listID + '/items_for.json').then (result) =>
        for element in result.data
          if !element.category
            element.category = 'Uncategorized'
          if !element.status
            element.status = 'new'
        $scope.data = result.data
        $scope.lastLoaded = Date.now()
    $scope.clearCart = (item, status) ->
      $http.post('/grocery_lists/' + $scope.listID + '/clear.json').then (result) =>
        $scope.loadData();    
    $scope.setStatus = (item, status) ->
      item.status = status
      $http.patch('/grocery_list_items/' + item.id + ".json", {grocery_list_item: {status: status}})
    $scope.loadData()
    
    $interval($scope.loadData, 5000)
angular.module('groceries', ['Devise', 'angular.filter'])
  .controller 'GroceriesController', GroceriesController

