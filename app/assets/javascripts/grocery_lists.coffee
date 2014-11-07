class GroceriesController
  constructor: ($scope, $http, Auth) ->
    $scope.quickAdd = () ->
      $http.post('/grocery_lists/' + dataID + '/quick_add.json', { quick_add: $scope.addText }).then (result) ->
        $scope.loadData();
        $scope.addText = ''
    $scope.loadData = () ->
      dataID = document.getElementById('app').getAttribute('data-grocery-list-id');
      $http.get('/grocery_lists/' + dataID + '/items_for.json').then (result) =>
        for element in result.data
          if !element.category
            element.category = 'Uncategorized'
          if !element.status
            element.status = 'new'
        $scope.data = result.data
    $scope.loadData()
    $scope.test = 'hello'
    $scope.setStatus = (item, status) ->
      item.status = status
      $http.patch('/grocery_list_items/' + item.id + ".json", {grocery_list_item: {status: status}})
    
angular.module('groceries', ['Devise', 'angular.filter'])
  .controller 'GroceriesController', GroceriesController

