angular.module('calendarApp').controller('calendarCtrl', ['$scope', '$log', '$timeout', 'redirectionSvc', 'messageModalSvc', function ($scope, $log, $timeout, redirectionSvc, messageModalSvc) {

    $scope.config = {
        scale: "Day",
        days: 30,
        startDate: "2017-04-18",
        timeHeaders: [
            { groupBy: "Month" },
            { groupBy: "Day", format: "d" }
        ],
        resources: [
            { name: "Room B", id: "B" },
            { name: "Room C", id: "C" },
            { name: "Room D", id: "D" },
            { name: "Room E", id: "E" }
        ]
    };

    $scope.dummyEvents = [
        {
            start: new DayPilot.Date("2017-04-18T10:00:00"),
            end: new DayPilot.Date("2017-04-18T14:00:00"),
            id: DayPilot.guid(),
            text: "First Event"
        }
    ];

    $scope.scale = "hours";
    $scope.businessOnly = true;

    $scope.$watch("scale", function () {
        $scope.schedulerConfig.timeline = getTimeline($scope.scheduler.visibleStart());
        $scope.schedulerConfig.timeHeaders = getTimeHeaders();
        $scope.schedulerConfig.scrollToAnimated = "fast";
        $scope.schedulerConfig.scrollTo = $scope.scheduler.getViewPort().start;  // keep the scrollbar position/by date
    });

    $scope.$watch("businessOnly", function () {
        $scope.schedulerConfig.timeline = getTimeline($scope.scheduler.visibleStart());
        $scope.schedulerConfig.scrollToAnimated = false;
        $scope.schedulerConfig.scrollTo = $scope.scheduler.getViewPort().start;  // keep the scrollbar position/by date
    });

    $scope.navigatorConfig = {
        selectMode: "month",
        showMonths: 3,
        skipMonths: 3,
        onTimeRangeSelected: function (args) {
            if ($scope.scheduler.visibleStart().getDatePart() <= args.day && args.day < $scope.scheduler.visibleEnd()) {
                $scope.scheduler.scrollTo(args.day, "fast");  // just scroll
            }
            else {
                loadEvents(args.day);  // reload and scroll
            }
        }
    };

    $scope.schedulerConfig = {
        visible: false, // will be displayed after loading the resources
        scale: "Manual",
        timeline: getTimeline(),
        timeHeaders: getTimeHeaders(),
        useEventBoxes: "Never",
        eventDeleteHandling: "Update",
        eventClickHandling: "Disabled",
        eventMoveHandling: "Disabled",
        eventResizeHandling: "Disabled",
        allowEventOverlap: false,
        onBeforeTimeHeaderRender: function (args) {
            args.header.html = args.header.html.replace(" AM", "a").replace(" PM", "p");  // shorten the hour header
        },
        onBeforeEventRender: function (args) {
            switch (args.data.tags.status) {
                case "free":
                    args.data.barColor = "green";
                    args.data.deleteDisabled = $scope.scale === "shifts";  // only allow deleting in the more detailed hour scale mode
                    break;
                case "waiting":
                    args.data.barColor = "orange";
                    args.data.deleteDisabled = true;
                    break;
                case "confirmed":
                    args.data.barColor = "#f41616";  // red            
                    args.data.deleteDisabled = true;
                    break;
            }
        },
        onEventDeleted: function (args) {
            var params = {
                id: args.e.id(),
            };

            //todo
            //$http.post("backend_delete.php", params).success(function () {
            //    $scope.scheduler.message("Deleted.");
            //});
            $scope.scheduler.message("Deleted.");

        },
        onTimeRangeSelected: function (args) {
            var dp = $scope.scheduler;

            var params = {
                start: args.start.toString(),
                end: args.end.toString(),
                resource: args.resource,
                scale: $scope.scale
            };

            
            //todo
            //$http.post("backend_create.php", params).success(function (data) {
            //    loadEvents();
            //    dp.message(data.message);
            //});
            loadEvents();
            dp.message('test data');

            dp.clearSelection();

        },
    };

    $scope.clear = function () {
        var dp = $scope.scheduler;
        var params = {
            start: dp.visibleStart(),
            end: dp.visibleEnd()
        };
        $http.post("backend_clear.php", params).success(function (data) {
            dp.message(data.message);
            loadEvents();
        });
    };

    $timeout(function () {
        dp = $scope.scheduler;  // debug
        loadResources();
        loadEvents(DayPilot.Date.today());
    });

    function loadEvents(day) {
        var from = $scope.scheduler.visibleStart();
        var to = $scope.scheduler.visibleEnd();
        if (day) {
            from = new DayPilot.Date(day).firstDayOfMonth();
            to = from.addMonths(1);
        }

        var params = {
            start: from.toString(),
            end: to.toString()
        };

        //todo
        //$http.post("backend_events.php", params).success(function (data) {
        //    $scope.schedulerConfig.timeline = getTimeline(day);
        //    $scope.schedulerConfig.scrollTo = day;
        //    $scope.schedulerConfig.scrollToAnimated = "fast";
        //    $scope.schedulerConfig.scrollToPosition = "left";
        //    $scope.events = data;
        //});

        $scope.schedulerConfig.timeline = getTimeline(day);
        $scope.schedulerConfig.scrollTo = day;
        $scope.schedulerConfig.scrollToAnimated = "fast";
        $scope.schedulerConfig.scrollToPosition = "left";
        $scope.events = $scope.dummyEvents;
    }

    function loadResources() {
        $scope.schedulerConfig.resources = $scope.config.resources;
        $scope.schedulerConfig.visible = true;
        //todo
        //$http.post("backend_resources.php").success(function (data) {
        //    $scope.schedulerConfig.resources = data;
        //    $scope.schedulerConfig.visible = true;
        //});
    }

    function getTimeline(date) {
        var date = date || DayPilot.Date.today();
        var start = new DayPilot.Date(date).firstDayOfMonth();
        var days = start.daysInMonth();

        var morningShiftStarts = 9;
        var morningShiftEnds = 13;
        var afternoonShiftStarts = 14;
        var afternoonShiftEnds = 18;

        if (!$scope.businessOnly) {
            var morningShiftStarts = 0;
            var morningShiftEnds = 12;
            var afternoonShiftStarts = 12;
            var afternoonShiftEnds = 24;
        }

        var timeline = [];

        var increaseMorning;  // in hours
        var increaseAfternoon;  // in hours
        switch ($scope.scale) {
            case "hours":
                increaseMorning = 1;
                increaseAfternoon = 1;
                break;
            case "shifts":
                increaseMorning = morningShiftEnds - morningShiftStarts;
                increaseAfternoon = afternoonShiftEnds - afternoonShiftStarts;
                break;
            default:
                throw "Invalid scale value";
        }

        for (var i = 0; i < days; i++) {
            var day = start.addDays(i);

            for (var x = morningShiftStarts; x < morningShiftEnds; x += increaseMorning) {
                timeline.push({ start: day.addHours(x), end: day.addHours(x + increaseMorning) });
            }
            for (var x = afternoonShiftStarts; x < afternoonShiftEnds; x += increaseAfternoon) {
                timeline.push({ start: day.addHours(x), end: day.addHours(x + increaseAfternoon) });
            }
        }

        return timeline;
    }

    function getTimeHeaders() {
        switch ($scope.scale) {
            case "hours":
                return [{ groupBy: "Month" }, { groupBy: "Day", format: "dddd dd" }, { groupBy: "Hour", format: "h tt" }];
                break;
            case "shifts":
                return [{ groupBy: "Month" }, { groupBy: "Day", format: "dddd d" }, { groupBy: "Cell", format: "tt" }];
                break;
        }
    }


    $scope.add = function () {
        $scope.dummyEvents.push(
                {
                    start: new DayPilot.Date("2017-04-18T10:00:00"),
                    end: new DayPilot.Date("2017-04-18T14:00:00"),
                    id: DayPilot.guid(),
                    text: "Simple Event"
                }
        );
    };

    $scope.move = function () {
        var event = $scope.dummyEvents[0];
        event.start = event.start.addDays(1);
        event.end = event.end.addDays(1);
    };

    $scope.rename = function () {
        $scope.dummyEvents[0].text = "New name";
    };

    $scope.message = function () {
        $scope.scheduler.message("Hi");
    };

}]);