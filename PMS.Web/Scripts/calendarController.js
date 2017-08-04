angular.module('calendarApp').controller('calendarCtrl', ['$scope', '$log', '$timeout', 'redirectionSvc', 'messageModalSvc', 'calendarSvc', function ($scope, $log, $timeout, redirectionSvc, messageModalSvc, calendarSvc) {
    var dpBookingResponseDto = [];
    var dpRoomsResponseDto = [];
    var pmsSession = window.PmsSession;
    var propertyId = pmsSession.GetItem("propertyid");
    $scope.duration = 'today';
    $scope.roomType = -1;
    $scope.roomStatus = 1;
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
        $scope.Bookings = response.Bookings;
        loadRooms();
        var day = $scope.day ? $scope.day : DayPilot.Date.today();
        $scope.schedulerConfig.timeline = getTimeline(day);
        $scope.schedulerConfig.scrollTo = day;
        $scope.schedulerConfig.scrollToAnimated = "fast";
        $scope.schedulerConfig.scrollToPosition = "left";
        $scope.events = convertBookingResponseToDayPilotResponse(response.Bookings);
        scheduler.dp.update();
        
    };   

    var onGetRoomBookingError = function (reason) {
        $scope.error = reason;
        $log.error(reason);
    };

    //var onGetRoomSuccess = function (response) {
    //    pmsSession.RemoveItem("propertyrooms");
    //    pmsSession.SetItem("propertyrooms", JSON.stringify(response.Rooms));
    //    var response = convertRoomResponseToDayPilotResponse(response.Rooms)
    //    $scope.schedulerConfig.resources = response;
    //    $scope.schedulerConfig.visible = true;
    //};

    //var onGetRoomError = function (reason) {
    //    $scope.error = reason;
    //    $log.error(reason);
    //};
    
    $scope.filterRoom = function () {
        var searchvalue = $('#searchRoom').val();
        if (!searchvalue || searchvalue === " " || searchvalue.length <= 0) {
            var roomData = pmsSession.GetItem("propertyrooms");
            showRoomsOnDaypilotGrid(JSON.parse(roomData));
            return;
        }
        var response = {};
        response.Rooms = {};
        var bookingData = $scope.Bookings;
        response.Rooms = applyRoomFilter(bookingData);
        showRoomsOnDaypilotGrid(response.Rooms);
    };

    $scope.setCalendarView = function (duration) {
        $('#searchRoom').val('');
        $scope.duration = duration;
        setSchedulerScale(duration);
        var day = $scope.day ? $scope.day : DayPilot.Date.today();
        $scope.loadEvents(day);
    };
    
    $scope.submit = function () {
        var selectedRoomType = $scope.selectedRoomTypes;
        //var roomStatus = $scope.selectedRoomStatus;
        // no filter applied
        if ((!selectedRoomType || selectedRoomType.length <= 0) //&& (!roomStatus || roomStatus.length <= 0)
            ) {
            alert('No filter criteria is selected');
            return;
        }
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
            $scope.schedulerConfig.cellWidth = 34;
            $scope.schedulerConfig.cellWidthSpec = 'Fixed';
        } else {
            $scope.schedulerConfig.cellWidthSpec = 'Auto';
        }
    });

    $scope.navigatorConfig = {
        selectMode: "month",
        showMonths: 3,
        skipMonths: 1,        
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
                $scope.loadEvents(args.day);  // reload and scroll
            }
        }
    };

    $scope.schedulerConfig = {
        visible: false, // will be displayed after loading the resources
        scale: "Manual",
        bubble: new DayPilot.Bubble(),
        timeline: getTimeline(),
        timeHeaders: getTimeHeaders(),
        useEventBoxes: "Never",
        eventDeleteHandling: "Disabled",
        eventClickHandling: "Disabled",
        eventMoveHandling: "Update",
        eventResizeHandling: "Disabled",
        allowEventOverlap: false,
        eventDoubleClickHandling: "Enabled",
        eventHoverHandling: "Bubble",
        timeRangeSelectingStartEndEnabled: true,
        eventResizingStartEndEnabled: true,
        eventMovingStartEndEnabled: true,
        dynamicEventRenderingCacheSweeping: true,
        //separators : [{color:"Red", location:"2017-07-30T08:00:00"}],
        onEventDoubleClick: function (args) {
            pmsSession.RemoveItem("bookingId");
            pmsSession.SetItem("bookingId", args.e.id());
            redirectionSvc.RedirectToCheckin();
        },
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
            if (args.e.id > -1) {
                args.e.bubbleHtml = "<div class='tooltip'><b>" + args.e.text + "</b><br>Start: " + new DayPilot.Date(args.e.start).toString("M/d/yyyy") + "<br>End: " + new DayPilot.Date(args.e.end).toString("M/d/yyyy") + "</div>";
            }
            //args.data.cssClass = "eventseparator";
            if (!args || !args.data || !args.data.tags || !args.data.tags.status) return;
            switch (args.data.tags.status.toLowerCase()) {
                case "available":
                    args.data.barColor = "green";
                    args.data.deleteDisabled = true;  // only allow deleting in the more detailed hour scale mode
                    break;
                case "reserved":
                    args.data.barColor = "orange";
                    args.data.deleteDisabled = true;
                    break;
                case "booked":
                    args.data.barColor = "#f41616";  // red            
                    args.data.deleteDisabled = true;
                    status = "Booked";
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
            pmsSession.SetItem("roomid", args.resource);
            pmsSession.SetItem("dtcheckout", params.end);
            var roomTypeId = getRoomTypeId($scope.Bookings, args.resource);
            pmsSession.SetItem("roomtypeid", roomTypeId);
            redirectionSvc.RedirectToCheckin();
        },
    };

    function getRoomTypeId(data, roomId) {
        var roomTypeId = '-1';
        var rooms = filterRoomsFromBookingResponse(data);
        if (!rooms || rooms.length <= 0) return roomTypeId;
        for (var i = 0; i < rooms.length; i++) {
            if (rooms[i].Id !== roomId) continue;
            roomTypeId = rooms[i].RoomType.Id;
            break;
        }
        return roomTypeId;
    }

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
        //loadRoomStatus();
        //loadRoomTypes();
        //loadRooms();
        $scope.loadEvents(DayPilot.Date.today());
    });
    
    function applyRoomFilter(data) {
        var response = {};
        response.Rooms = [];
        if (!data || data.length <= 0) return response.Rooms;
        var searchvalue = $('#searchRoom').val();
        // iterate Bookings
        for (var i = 0; i < data.length; i++) {
            if (!data[i] || !data[i].RoomBookings || data[i].RoomBookings.length <= 0) continue;
            // iterate RoomBookings
            for (var j = 0; j < data[i].RoomBookings.length; j++) {
                if (!data[i] || !data[i].RoomBookings[j]) continue;
                var room = data[i].RoomBookings[j].Room;
                var guest = data[i].RoomBookings[j].Guest;
                
                if (room && $.trim(room.Number.toLowerCase()).indexOf($.trim(searchvalue.toLowerCase())) >= 0) {
                    // check if room already added 
                    if (response.Rooms && response.Rooms.length > 0) {
                        var found = false;
                        for (var k = 0; k < response.Rooms.length; k++) {
                            if (parseInt(data[i].RoomBookings[j].Room.Id) !== parseInt(response.Rooms[k].Id)) continue;
                            found = true;
                            break;
                        }
                        if (!found) {
                            response.Rooms.push(data[i].RoomBookings[j].Room);
                        }
                        
                    }else{
                        response.Rooms.push(data[i].RoomBookings[j].Room);
                    }
                    continue;
                }
                if (guest && guest.Id > 0 &&
                    ($.trim(guest.FirstName.toLowerCase()).indexOf($.trim(searchvalue.toLowerCase())) >= 0
                    || $.trim(guest.LastName.toLowerCase()).indexOf($.trim(searchvalue.toLowerCase())) >= 0)) {

                    if (response.Rooms && response.Rooms.length > 0) {
                        var found = false;
                        // check if room already added 
                        for (var k = 0; k < response.Rooms.length; k++) {
                            if (parseInt(data[i].RoomBookings[j].Room.Id) !== parseInt(response.Rooms[k].Id)) continue;
                            found = true;
                            break;
                        }
                        if (!found) {
                            response.Rooms.push(data[i].RoomBookings[j].Room);
                        }
                    } else {
                        response.Rooms.push(data[i].RoomBookings[j].Room);
                    }
                    continue;
                }
            }
        }
        return response.Rooms;
    }

    function convertBookingResponseToDayPilotResponse(bookingResponse) {
        dpBookingResponseDto = [];
        for (var i = 0; i < bookingResponse.length; i++) {
            var booking = bookingResponse[i];
            if (!booking || booking.Id <= 0) continue;

            var data = booking.RoomBookings;
            for (var j = 0; j < booking.RoomBookings.length; j++) {
                if (!data[j]) continue;
                var dpBookingData = {};
                dpBookingData.tags = {};

                dpBookingData.start = booking.CheckinTime;
                dpBookingData.end = booking.CheckoutTime;
                dpBookingData.resource = data[j].Room.Id;
                if (data[j].Guest.FirstName) {
                    dpBookingData.text = "Booked for : " + data[j].Guest.LastName + ", " + data[j].Guest.FirstName;
                }
                dpBookingData.tags.status = data[j].Room.RoomStatus.Name;
                dpBookingData.id = booking.Id;

                dpBookingResponseDto.push(dpBookingData);
            }
        }
        return dpBookingResponseDto;
    }

    function convertRoomResponseToDayPilotResponse(roomsResponse) {
        dpRoomsResponseDto = [];        
        for (var i = 0; i < roomsResponse.length; i++) {
            var room = roomsResponse[i];            
            if (!room) continue;

            var dpRoomData = {};
            dpRoomData.name = room.Number;
            dpRoomData.id = room.Id;

            dpRoomsResponseDto.push(dpRoomData);
        }
        return dpRoomsResponseDto;
    }

    $scope.update = function () {
        
    };

    $scope.loadEvents = function (day) {
        
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

        propertyId = pmsSession.GetItem("propertyid");
        // Show loading message
        var messageModal = messageModalSvc.ShowMessage("Loading ...", $scope);
        calendarSvc.GetRoomBooking(propertyId, params).then(onGetRoomBookingSuccess, onGetRoomBookingError)['finally'](function () {
            messageModalSvc.CloseMessage(messageModal);
        });
    };

    function loadRooms() {
        var response = {};
        response.Rooms = {};
        var roomData = pmsSession.GetItem("propertyrooms");
        //if room data is not in session storage then filter from 
        if (!roomData) {
            response.Rooms = filterRoomsFromBookingResponse($scope.Bookings);
            //if room data is not in session storage then make ajax call
            //var messageModal = messageModalSvc.ShowMessage("Loading...", $scope);
            //calendarSvc.GetRoomByProperty(propertyId).then(onGetRoomSuccess, onGetRoomError)['finally'](function () {
            //    messageModalSvc.CloseMessage(messageModal);
            //});
        }
        else {
            response.Rooms = JSON.parse(roomData);           
        }
        pmsSession.RemoveItem("propertyrooms");
        pmsSession.SetItem("propertyrooms", JSON.stringify(response.Rooms));
        showRoomsOnDaypilotGrid(response.Rooms);
    }

    function showRoomsOnDaypilotGrid(rooms) {
        var response = convertRoomResponseToDayPilotResponse(rooms)
        $scope.schedulerConfig.resources = response;
        $scope.schedulerConfig.visible = true;
    }
    
    function filterRoomsFromBookingResponse(data) {
        var response = {};
        response.Rooms = [];
        if (!data || data.length <= 0) return response.Rooms;
        // iterate Bookings
        for (var i = 0; i < data.length; i++) {
            if (!data[i] || !data[i].RoomBookings || data[i].RoomBookings.length <= 0) continue;
            // iterate RoomBookings
            for (var j = 0; j < data[i].RoomBookings.length; j++) {
                if (!data[i] || !data[i].RoomBookings[j] || !data[i].RoomBookings[j].Room) continue;
                if (response.Rooms && response.Rooms.length > 0) {
                    var found = false;
                    // check if room already added 
                    for (var k = 0; k < response.Rooms.length; k++) {
                        if (parseInt(data[i].RoomBookings[j].Room.Id) !== parseInt(response.Rooms[k].Id)) continue;
                        found = true;
                        break;
                    }
                    if (!found) {
                        response.Rooms.push(data[i].RoomBookings[j].Room);
                    }
                } else {
                    response.Rooms.push(data[i].RoomBookings[j].Room);
                }
            }
        }
        return response.Rooms;
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

    //function loadRoomStatus() {
    //    $scope.roomStatus = [
    //            { "Id": 1, "Name": "Available" },
    //            { "Id": 2, "Name": "Reserved" },
    //            { "Id": 3, "Name": "Booked" },
    //    ];
    //}
    //function loadRoomTypes() {
    //    // Show loading message
    //    var roomTypeData = pmsSession.GetItem("roomtypedata");
    //    //TODO make ajax call in case data is not in session 
    //    //if roomtype data is not in session storage then make ajax call
    //    if (!roomTypeData) {
    //        var messageModal = messageModalSvc.ShowMessage("Loading...", $scope);
    //        calendarSvc.GetRoomByProperty(propertyId).then(onGetRoomSuccess, onGetRoomError)['finally'](function () {
    //            messageModalSvc.CloseMessage(messageModal);
    //        });
    //    } else {
    //        $scope.roomTypes = $.parseJSON(roomTypeData);
    //    }
    //}

    function getTimeHeaders() {
        switch ($scope.scale) {
            case "hour":
                return [{ groupBy: "Month" }, { groupBy: "Day", format: "dddd dd" }, { groupBy: "Hour", format: "h tt" }];
                break;
            case "month":
                return [{ groupBy: "Month" }, { groupBy: "Day", format: "ddd d" }];
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
