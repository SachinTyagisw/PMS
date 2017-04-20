angular.module('calendarApp')
    .service('redirectionSvc', ['$location', function ($location) {
        return {
            'RedirectToHome': function () {
                $location.url("/view/Home");
            },
            'RedirectToProduct': function () {
                $location.url("/view/Product");
            },
            'RedirectToLogin': function () {
                $location.url("/");
            }
        };
    }]);