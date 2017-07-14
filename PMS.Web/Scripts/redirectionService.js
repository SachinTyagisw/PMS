angular.module('calendarApp')
    .service('redirectionSvc', ['$location', '$window', function ($location, $window) {
        return {
            'RedirectToCheckin': function () {
                $window.location.href = '/Booking/Checkin';
            },
            'RedirectToLogin': function () {
                $location.url("/");
            }
        };
    }]);