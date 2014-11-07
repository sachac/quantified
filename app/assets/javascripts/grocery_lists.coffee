class GroceriesController
  constructor: ($scope, $http, Auth) ->
    $scope.loadData = () ->
      dataID = document.getElementById('app').getAttribute('data-grocery-list-id');
      $http.get('/grocery_lists/' + dataID + '/items_for.json').then (result) =>
        $scope.data = result.data
    $scope.loadData()
    $scope.test = 'hello'
    $scope.setStatus = (item, status) ->
      $http.patch('/grocery_list_items/' + item.id + ".json", {grocery_list_item: {status: status}}).then (result) =>
        $scope.loadData()
    
angular.module('groceries', ['Devise', 'ngRoute', 'ngResource'])
  .controller 'GroceriesController', GroceriesController

