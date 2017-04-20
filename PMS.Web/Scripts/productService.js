angular.module('vendorApp').service('productSvc', ['$http', '$resource', 'urls', function($http, $resource, urls) {

  var getProducts = function(token, top, skip, orgName) {
    $http.defaults.headers.common = {
      'Authorization': '$token ' + token,
      'OrgName': orgName
    };
    var url = urls.BASE_URL + 'Product/GetProducts?$top=' + top + '&$skip=' + skip;
    return $http.get(url)
      .then(function(response) {
        return response.data;
      });
  };

  return {
    'GetProducts': getProducts
  };
}]);