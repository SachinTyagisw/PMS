angular.module('calendarApp').controller('calendarCtrl', ['$scope', '$log', '$timeout', 'redirectionSvc', 'messageModalSvc', 'calendarSvc', function ($scope, $log, $timeout, redirectionSvc, messageModalSvc, calendarSvc) {
    var dpBookingResponseDto = [];
    var dpRoomsResponseDto = [];
    var pmsSession = window.PmsSession;
    var propertyId = pmsSession.GetItem("propertyid");
    $scope.duration = 'today';
    $scope.roomType = 0;
    $scope.scale = "hour";
    var onUpdateBookingSuccess = function (response) {
        if (response && response.data && response.data.ResponseStatus){
            $scope.message = response.data.StatusDescription;
        }        
    };

    var onUpdateBookingError = function (reason) {
        $scope.error = reason;
        $log.error(reason);
    };

    var onGetRoomBookingSuccess = function (response) {
        var day = $scope.day ? $scope.day : DayPilot.Date.today();
        $scope.schedulerConfig.timeline = getTimeline(day);
        $scope.schedulerConfig.scrollTo = day;
        $scope.schedulerConfig.scrollToAnimated = "fast";
        $scope.schedulerConfig.scrollToPosition = "left";
        $scope.events = convertBookingResponseToDayPilotResponse(response.Bookings);
    };   

    var onGetRoomBookingError = function (reason) {
        $scope.error = reason;
        $log.error(reason);
    };

    var onGetRoomSuccess = function (response) {
        pmsSession.SetItem("propertyrooms", JSON.stringify(response.Rooms));
        //todo: apply roomtype filter if roomtype is > 0
        var roomtype = $scope.roomType;
        var response = convertRoomResponseToDayPilotResponse(response.Rooms)
        $scope.schedulerConfig.resources = response;
        $scope.schedulerConfig.visible = true;
    };

    var onGetRoomError = function (reason) {
        $scope.error = reason;
        $log.error(reason);
    };
    
    $scope.$watch("roomType", function () {
        loadRooms();
    });
    
    $scope.filterRoom = function () {        
        loadRooms();
    };

    $scope.setCalendarView = function(duration) {
        $scope.duration = duration;
        setSchedulerScale(duration);
        var day = $scope.day ? $scope.day : DayPilot.Date.today();
        loadEvents(day);
    };

    $scope.changeRoomType = function () {
        loadRooms();
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

    $scope.$watch("scale", function () {
        $scope.schedulerConfig.timeline = getTimeline($scope.scheduler.visibleStart());
        $scope.schedulerConfig.timeHeaders = getTimeHeaders();
        $scope.schedulerConfig.scrollToAnimated = "fast";
        $scope.schedulerConfig.scrollTo = $scope.scheduler.getViewPort().start;  // keep the scrollbar position/by date
        if ($scope.scale === "month") {
            $scope.schedulerConfig.cellWidth = 100;
            $scope.schedulerConfig.cellWidthSpec = 'Fixed';
        } else {
            $scope.schedulerConfig.cellWidthSpec = 'Auto';
        }
    });

    $scope.navigatorConfig = {
        selectMode: "month",
        showMonths: 3,
        skipMonths: 3,        
        onTimeRangeSelected: function (args) {
            if ($scope.duration === 'today') {
                args.day = DayPilot.Date.today();
            }
            // to scroll calendar to selected date
            $scope.day = args.day;
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
        eventMoveHandling: "Update",
        eventResizeHandling: "Disabled",
        allowEventOverlap: false,
        //onBeforeCellRender: function (args) {
        //},
        onEventMoved: function (args) {
            var bookingRequestDto = {};
            bookingRequestDto.Booking = {};
            var booking = {};
            var roomBookings = [];
            var roomBooking = {};

            booking.Id = args.e.id();
            booking.CheckinTime = args.newStart.value;
            booking.CheckoutTime = args.newEnd.value;

            roomBooking.RoomId = args.newResource;
            roomBookings.push(roomBooking);

            booking.RoomBookings = roomBookings;
            bookingRequestDto.Booking = booking;

            calendarSvc.UpdateBooking(bookingRequestDto).then(onUpdateBookingSuccess, onUpdateBookingError)['finally'](function () {
                messageModalSvc.CloseMessage(messageModal);
            });
            //$("#msg").html(args.start + " " + args.end + " " + args.resource);
        },
        //onEventMove: function (args) {
        //    //alert(args.start);
        //    //alert(args.end);
        //    //alert(args.resource);
        //    //$("#msg").html(args.start + " " + args.end + " " + args.resource);
        //},
        //onEventMoving: function (args) {
        //    //alert(args.start);
        //    //alert(args.end);
        //    //alert(args.resource);
        //    //$("#msg").html(args.start + " " + args.end + " " + args.resource);
        //},        
        onBeforeTimeHeaderRender: function (args) {
            args.header.html = args.header.html.replace(" AM", "AM").replace(" PM", "PM");  // shorten the hour header
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
                    status = "Confirmed";
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
            var params = {
                start: new DayPilot.Date(args.start).toString("MM/dd/yyyy h:mm tt"),
                end: new DayPilot.Date(args.end).toString("MM/dd/yyyy h:mm tt"),
                resource: args.resource,
                scale: $scope.scale
            };
            
            pmsSession.RemoveItem("dtcheckin");
            pmsSession.RemoveItem("dtcheckout");
            pmsSession.SetItem("dtcheckin", params.start);
            pmsSession.SetItem("dtcheckout", params.end);
            redirectionSvc.RedirectToCheckin();
        },
    };

    //$scope.clear = function () {
    //    var dp = $scope.scheduler;
    //    var params = {
    //        start: dp.visibleStart(),
    //        end: dp.visibleEnd()
    //    };
    //    //todo
    //    $http.post("backend_clear.php", params).success(function (data) {
    //        dp.message(data.message);
    //        loadEvents();
    //    });
    //};

    $timeout(function () {
        dp = $scope.scheduler;  // debug
        loadRooms();
        loadEvents(DayPilot.Date.today());
    });

    function convertBookingResponseToDayPilotResponse(bookingResponse) {
        dpBookingResponseDto = [];
        for (var i = 0; i < bookingResponse.length; i++) {
            var booking = bookingResponse[i];
            if (!booking) continue;

            var data = booking.RoomBookings;
            for (var j = 0; j < booking.RoomBookings.length; j++) {
                if (!data[j]) continue;
                var dpBookingData = {};
                dpBookingData.tags = {};

                dpBookingData.start = booking.CheckinTime;
                dpBookingData.end = booking.CheckoutTime;
                dpBookingData.resource = data[j].Room.Id;
                dpBookingData.text = "Booked for : " + data[j].Guest.LastName +", " + data[j].Guest.FirstName;
                dpBookingData.tags.status = "confirmed";
                dpBookingData.id = booking.Id;

                dpBookingResponseDto.push(dpBookingData);
            }
        }
        return dpBookingResponseDto;
    }

    function convertRoomResponseToDayPilotResponse(roomsResponse) {
        var searchvalue = $('#searchRoom').val();
        dpRoomsResponseDto = [];        
        for (var i = 0; i < roomsResponse.length; i++) {
            var room = roomsResponse[i];
            if (!room || (searchvalue && searchvalue.length > 0 && room.Number.toLowerCase().indexOf(searchvalue.toLowerCase()) < 0)) continue;

            var dpRoomData = {};
            dpRoomData.name = room.Number;
            dpRoomData.id = room.Id;

            dpRoomsResponseDto.push(dpRoomData);
        }
        return dpRoomsResponseDto;
    }

    function loadEvents(day) {
        var duration = getDaysBasedOnDuration();
        var from = new DayPilot.Date(day);
        //var to = $scope.scheduler.visibleEnd();
        if (!day) {
            from = $scope.scheduler.visibleStart();            
        }
        var to = from.addDays(duration);
        var params = {
            start: from.toString(),
            end: to.toString()
        };

        // Show loading message
        var messageModal = messageModalSvc.ShowMessage("Loading ...", $scope);
        calendarSvc.GetRoomBooking(propertyId, params).then(onGetRoomBookingSuccess, onGetRoomBookingError)['finally'](function () {
            messageModalSvc.CloseMessage(messageModal);
        });       
    }

    function loadRooms() {                
        // Show loading message
        var roomData = pmsSession.GetItem("propertyrooms");
        //if room data is not in session storage then make ajax call
        if (!roomData) {
            var messageModal = messageModalSvc.ShowMessage("Loading...", $scope);
            calendarSvc.GetRoomByProperty(propertyId).then(onGetRoomSuccess, onGetRoomError)['finally'](function () {
                messageModalSvc.CloseMessage(messageModal);
            });
        }
        else {
            var response = {};
            response.Rooms = {};
            response.Rooms = JSON.parse(roomData);
            onGetRoomSuccess(response);
        }
    }    

    function getDaysBasedOnDuration() {        
        if ($scope.duration === 'daily') return 1;
        if ($scope.duration === 'weekly') return 7;
        if ($scope.duration === 'monthly') return 30;
        else return 1;
    }

    function setSchedulerScale(duration) {
        if (duration === 'today') {
            $scope.scale = "hour";
            $scope.day = DayPilot.Date.today();
        }
            
        if (duration === 'daily') $scope.scale = "hour";
        if (duration === 'weekly') $scope.scale = "week";
        if (duration === 'monthly') $scope.scale = "month";
    }

    function getTimeline(selecteddate) {
        var date = null;
        if ($scope.duration === 'today') {
            date = DayPilot.Date.today();
        } else {
            date = selecteddate || DayPilot.Date.today();
        }
         
        //var start = new DayPilot.Date(date).firstDayOfMonth();
        var start = new DayPilot.Date(date);
        //days on the basis of UI selection
        var days = getDaysBasedOnDuration();
        var morningShiftStarts = 0;
        var morningShiftEnds = 24;
        var afternoonShiftStarts = 12;
        var afternoonShiftEnds = 24;
        var timeline = [];
        var increaseMorning;  // in hours
        var increaseAfternoon;  // in hours
        switch ($scope.scale) {
            case "hour":
                increaseMorning = 1;
                increaseAfternoon = 1;
                break;
        }

        if (days === 1) {
            for (var i = 0; i < days; i++) {
                var day = start.addDays(i);
                for (var x = morningShiftStarts; x < morningShiftEnds; x += increaseMorning) {
                    timeline.push({ start: day.addHours(x), end: day.addHours(x + increaseMorning) });
                }
            }
        } else {
            for (var i = 0; i < days; i++) {
                var day = start.addDays(i);
                timeline.push({ start: day, end: day.addDays(1) });
            }
        }
        return timeline;
    }

    function getTimeHeaders() {
        switch ($scope.scale) {
            case "hour":
                return [{ groupBy: "Month" }, { groupBy: "Day", format: "dddd dd" }, { groupBy: "Hour", format: "h tt" }];
                break;
            case "month":
                return [{ groupBy: "Month" }, { groupBy: "Day", format: "dddd d" }];
                break;
            case "week":
                return [{ groupBy: "Month" }, { groupBy: "Day", format: "dddd d" }];
                break;
        }
    }
}]);

//dp test data
//var dummyBookingData = [
//                            {
//                                start: new DayPilot.Date("2017-04-20T10:00:00"),
//                                end: new DayPilot.Date("2017-04-20T11:00:00"),
//                                id: DayPilot.guid(),
//                                text: "First Event123",
//                                tags: {
//                                    status: "confirmed"
//                                },
//                                resource: 1
//                            }
//];

//dummy data
//$scope.config = {
//    scale: "Day",
//    days: 10,
//    startDate: DayPilot.Date.today(),
//    timeHeaders: [
//        { groupBy: "Month" },
//        { groupBy: "Day", format: "d" }
//    ],
//    resources: [
//        { name: "Room B", id: 1 },
//        { name: "Room C", id: 2 },
//        { name: "Room D", id: 3 },
//        { name: "Room E", id: 4 }
//    ]
//};    
