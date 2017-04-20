angular.module('vendorApp').controller('productCntrl', ['$scope', '$log', '$modal', 'tokenSvc', 'redirectionSvc', 'productSvc', 'userSvc', 'messageModalSvc', function($scope, $log, $modal, tokenSvc, redirectionSvc, productSvc, userSvc, messageModalSvc) {

  $scope.validToken = tokenSvc.GetToken();
  if (!$scope.validToken) {
    $log.info('Token is not available');
    return;
  }
  
  $scope.isAuthenticated = userSvc.IsAuthenticated();
  var userDetails = userSvc.GetUserDetails();
  if (userDetails) {
    var fName = userDetails.FirstName;
    var lName = userDetails.LastName;
    var name = fName;
    if (lName) {
      name = name + lName;
    }
    $scope.name = name;
  }

  var skip = null;
  var cellTemplate = '<div class="ngCellText" data-ng-model="row"><button data-ng-click="updateSelectedRow(row,$event)">Edit</button></div>'

  $scope.options = [{
    name: "Select Organisation",
    id: -1
  }, {
    name: "Amazon",
    id: 1
  }, {
    name: "Flipkart",
    id: 2
  }];

  $scope.selectedOption = $scope.options[0];

  $scope.setPagingData = function(data, pageSize, page) {
    var pagedData = data.slice((page - 1) * pageSize, page * pageSize);
    $scope.productData = pagedData;
    $scope.totalServerItems = data.length;
    if (!$scope.$$phase) {
      $scope.$apply();
    }
  };

  var onGetProductSuccess = function(response) {
    $scope.products = response.Items;
    if (!$scope.products) {
      $scope.error = 'No data available';
      return;
    }
    $scope.error = '';
    $scope.productData = $scope.products;
    $scope.setPagingData($scope.products, $scope.pagingOptions.pageSize, $scope.pagingOptions.currentPage);
  };

  var onGetProductError = function(reason) {
    $scope.error = reason;
    $scope.isAuthenticated = false;
  };

  $scope.Logout = function() {
    $scope.validToken = '';
    $scope.isAuthenticated = false;
    redirectionSvc.RedirectToLogin();
  };

  // ui-grid setting start
  $scope.filterOptions = {
    filterText: "",
    useExternalFilter: true
  };

  $scope.totalServerItems = 0;

  $scope.pagingOptions = {
    pageSizes: [10, 50, 100],
    pageSize: 10,
    currentPage: 1
  };

  $scope.filter = function() {
    var filterText = '';
    if ($scope.filterOptions.filterText === '') {
      $scope.filterOptions.filterText = filterText;
    } else if ($scope.filterOptions.filterText === filterText) {
      $scope.filterOptions.filterText = '';
    }
  };

  $scope.getPagedDataAsync = function(pageSize, page, searchText) {
    pageSize = $scope.pagingOptions.pageSize;
    setTimeout(function() {
      // when data is already cached 
      if ($scope.productData) {
        $scope.setPagingData($scope.products, pageSize, page);
      } else {
        var data;
        var top = pageSize;
        var skip = null;
        var orgName = $scope.selectedOption.name;
        if (page > 1) {
          skip = pageSize * page;
        }

        // Show loading message
        var messageModal = messageModalSvc.ShowMessage("Loading Products...", $scope);
        productSvc.GetProducts($scope.validToken, null, null, orgName).then(onGetProductSuccess, onGetProductError)['finally'](function() {
          messageModalSvc.CloseMessage(messageModal);
        });
      }
    }, 100);
  };

  $scope.$watch('pagingOptions', function(newVal, oldVal) {
    if (newVal !== oldVal && newVal.currentPage !== oldVal.currentPage) {
      $scope.getPagedDataAsync($scope.pagingOptions.pageSize, $scope.pagingOptions.currentPage, $scope.filterOptions.filterText);
    }
  }, true);

  $scope.$watch('filterOptions', function(newVal, oldVal) {
    if (newVal !== oldVal) {
      $scope.getPagedDataAsync($scope.pagingOptions.pageSize, $scope.pagingOptions.currentPage, $scope.filterOptions.filterText);
    }
  }, true);

  $scope.myHeaderCellTemplate = '<div class="ngHeaderSortColumn {{col.headerClass}}" ng-style="{cursor: col.cursor}" ng-class="{ ngSorted: !noSortVisible }">' +
    '<div ng-click="col.sort($event)" ng-class="\'colt\' + col.index" class="ngHeaderText">{{col.displayName}}</div>' +
    '<div class="ngSortButtonDown" ng-show="col.showSortButtonDown()"></div>' +
    '<div class="ngSortButtonUp" ng-show="col.showSortButtonUp()"></div>' +
    '<div class="ngSortPriority">{{col.sortPriority}}</div>' +
    '</div>' +
    '<input type="text" ng-click="stopClickProp($event)" placeholder="Filter..." ng-model="col.filterText" ng-style="{ \'width\' : col.width - 14 + \'px\' }" style="position: absolute; top: 30px; bottom: 30px; left: 0; bottom:0;"/>' +
    '<div ng-show="col.resizable" class="ngHeaderGrip" ng-click="col.gripClick($event)" ng-mousedown="col.gripOnMouseDown($event)"></div>';

  $scope.gridOptions = {
    data: 'productData',
    enablePaging: true,
    showFooter: true,
    enableCellSelection: true,
    enableRowSelection: false,
    totalServerItems: 'totalServerItems',
    filterOptions: $scope.filterOptions,
    pagingOptions: $scope.pagingOptions,
    columnDefs: [{
      field: 'ImageUrl',
      displayName: 'Image',
      cellTemplate: '<div><img ng-src="{{row.getProperty(\'ImageUrl\')}}"></img></div>'
    }, {
      field: 'ProductSku',
      displayName: 'ISBN',
      enableCellEdit: false
    }, {
      field: 'Name',
      displayName: 'Book Name',
      cellTemplate: '<div tooltip="{{row.getProperty(\'Name\')}}" tooltip-append-to-body="true" tooltip-placement="right" >{{row.getProperty(col.field)}}</div>',
      headerCellTemplate: $scope.myHeaderCellTemplate

    }, {
      field: 'Owner',
      displayName: 'Author'
    }, {
      field: 'ListedPrice',
      displayName: 'Listed Price',
      enableCellEdit: true,
    }, {
      field: 'LowestPrice',
      displayName: 'Lowest Price'
    }, {
      field: 'CurrentStockOnProductApi',
      displayName: 'Stock on Product Api'
    }, {
      field: '',
      cellTemplate: cellTemplate
    }]
  };

  $scope.updateSelectedRow = function(row) {
    $scope.myrow = row.entity;
    var modalInstance = $modal.open({
      templateUrl: 'myModalContent.html',
      controller: ModalInstanceCtrl,
      resolve: {
        items: function() {
          return row.entity;
        }
      }
    });
  }

  $scope.save = function() {
    console.log($modal);
    $modal.dismiss('cancel');
  }

  $scope.GetProducts = function() {
    if ($scope.selectedOption.id <= 0) {
      alert('Please select organisation');
      return;
    }
    var orgName = $scope.selectedOption.name;
    $scope.getPagedDataAsync($scope.pagingOptions.pageSize, $scope.pagingOptions.currentPage);
    //productSvc.GetProducts($scope.validToken, top, skip, orgName).then(onGetProductSuccess, onGetProductError);
  };

}]);

var ModalInstanceCtrl = function($scope, $modalInstance, items) {

  $scope.items = items;
  var listedPrice = items.ListedPrice;

  $scope.ok = function() {
    var tt1 = items.ListedPrice;
    $modalInstance.close();
  };

  $scope.cancel = function() {
    items.ListedPrice = listedPrice;
    $modalInstance.dismiss('cancel');
  };
};