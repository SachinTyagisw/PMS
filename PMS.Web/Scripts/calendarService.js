angular.module('calendarApp').service('calendarSvc', ['$http', '$resource', 'urls', '$filter', function ($http, $resource, urls, $filter) {

    var getRoomBooking = function (propertyId, params) {
    //$http.defaults.headers.common = {
    //  'Authorization': '$token ' + token,
    //  'OrgName': orgName
        //};     

     var stDate = $filter('date')(Date.parse(params.start), 'yyyy-MM-dd');
     var endDate = $filter('date')(Date.parse(params.end), 'yyyy-MM-dd');
     var url = urls.BASE_URL + 'Booking/' + propertyId + '/GetBooking?startdate=' + stDate + '&enddate=' + endDate;

     return $http.get(url)
      .then(function(response) {
        return response.data;
          });
    };

    var getRoomByProperty = function (propertyId) {
        var url = urls.BASE_URL + 'Room/GetRoomByProperty/' + propertyId;
        return $http.get(url)
         .then(function (response) {
             return response.data;
         });
    };

      return {
                'GetRoomBooking': getRoomBooking,
                'GetRoomByProperty': getRoomByProperty
      };
}]);