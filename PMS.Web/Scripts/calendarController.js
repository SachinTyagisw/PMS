angular.module('calendarApp').controller('calendarCtrl', ['$scope', '$log', '$timeout', 'redirectionSvc', 'messageModalSvc', 'calendarSvc', function ($scope, $log, $timeout, redirectionSvc, messageModalSvc, calendarSvc) {

    function convertBookingResponseToDayPilotResponse(bookingResponse) {
        
    }

    var dummyBookingData = [
                                {
                                    start: new DayPilot.Date("2017-04-20T10:00:00"),
                                    end: new DayPilot.Date("2017-04-20T11:00:00"),
                                    // id: DayPilot.guid(),
                                    text: "First Event123",
                                    tags: {
                                        status: "confirmed"
                                    },
                                    resource: 1
                                }
    ];

    var onGetRoomBookingSuccess = function (response) {
        var day = getTimeline(DayPilot.Date.today());
        $scope.schedulerConfig.timeline = day;
        $scope.schedulerConfig.scrollTo = day;
        $scope.schedulerConfig.scrollToAnimated = "fast";
        $scope.schedulerConfig.scrollToPosition = "left";
        convertBookingResponseToDayPilotResponse(response.Bookings);
        //$scope.events = response;
    };

    var onGetRoomBookingError = function (reason) {
        $scope.error = reason;
        $log.error(reason);
    };

    $scope.config = {
        scale: "Day",
        days: 10,
        startDate: DayPilot.Date.today(),
        timeHeaders: [
            { groupBy: "Month" },
            { groupBy: "Day", format: "d" }
        ],
        resources: [
            { name: "Room B", id: 1 },
            { name: "Room C", id: 2 },
            { name: "Room D", id: 3 },
            { name: "Room E", id: 4 }
        ]   
    };

    $scope.add = function () {
        $scope.events.push(
                {
                    start: new DayPilot.Date("2017-04-21T10:00:00"),
                    end: new DayPilot.Date("2017-04-21T14:00:00"),
                    id: DayPilot.guid(),
                    text: "Simple Event",
                    tags: {
                        status: "confirmed"
                    },
                    resource: "C"
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
        $scope.scheduler.message("Hi");
    };
  
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
        //todo
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
        //if (day) {
        //    from = new DayPilot.Date(day).firstDayOfMonth();
        //    to = from.addMonths(1);
        //}

        var params = {
            start: from.toString(),
            end: to.toString()
        };

        // Show loading message
        //var messageModal = messageModalSvc.ShowMessage("Loading Calendar...", $scope);
        calendarSvc.GetRoomBooking(params).then(onGetRoomBookingSuccess, onGetRoomBookingError)['finally'](function () {
            messageModalSvc.CloseMessage(messageModal);
        });       

        //$scope.events = calendarSvc.GetRoomBooking(params);
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
        //var start = new DayPilot.Date(date).firstDayOfMonth();
        var start = new DayPilot.Date(date);
        //var days = start.daysInMonth();
        var days = 7;

        var morningShiftStarts = 0;
        var morningShiftEnds = 12;
        var afternoonShiftStarts = 12;
        var afternoonShiftEnds = 24;

        //if (!$scope.businessOnly) {
        //    var morningShiftStarts = 0;
        //    var morningShiftEnds = 12;
        //    var afternoonShiftStarts = 12;
        //    var afternoonShiftEnds = 24;
        //}

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

}]);