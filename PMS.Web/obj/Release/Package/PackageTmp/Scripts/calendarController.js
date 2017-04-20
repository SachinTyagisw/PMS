angular.module('calendarApp').controller('calendarCtrl', ['$scope', '$log', 'redirectionSvc', 'messageModalSvc', function ($scope, $log, redirectionSvc, messageModalSvc) {

    $scope.config = {
        startDate: "2014-09-01",
        viewType: "Week"
    };

    $scope.events = [
        {
            start: new DayPilot.Date("2014-09-01T10:00:00"),
            end: new DayPilot.Date("2014-09-01T14:00:00"),
            id: DayPilot.guid(),
            text: "First Event"
        }
    ];

    $scope.add = function () {
        $scope.events.push(
                {
                    start: new DayPilot.Date("2014-09-01T10:00:00"),
                    end: new DayPilot.Date("2014-09-01T12:00:00"),
                    id: DayPilot.guid(),
                    text: "Simple Event"
                }
        );
    };

    $scope.move = function () {
        var event = $scope.events[0];
        event.start = event.start.addDays(1);
        event.end = event.end.addDays(1);
    };

    $scope.rename = function () {
        $scope.events[0].text = "New name";
    };

    $scope.message = function () {
        $scope.dp.message("Hi");
    };

}]);