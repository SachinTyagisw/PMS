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

    var updateBooking = function (booking) {
        var url = urls.BASE_URL + 'Booking/UpdateBooking';
        return $http.put(url, JSON.stringify(booking), null)
         .then(function (response) {
             return response;
         });
    };

      return {
                'GetRoomBooking': getRoomBooking,
                'GetRoomByProperty': getRoomByProperty,
                'UpdateBooking': updateBooking
      };
}]);