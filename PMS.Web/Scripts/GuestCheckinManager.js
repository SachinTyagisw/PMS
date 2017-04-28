(function (win) {

    var propertyId = null;
    var pmsService = new window.PmsService();
    var pmsSession = window.PmsSession;
    var args = {};
    var guestCheckinManager = {
        
        Initialize: function () {                       

            ajaxHandlers();
            getRoomTypes();
            getRoomRateTypes();
            getRooms();
        },

        SetPropertyId: function (id) {
            this.propertyId = id;
        },

        GetPropertyId: function () {
            return this.propertyId;
        },

        BindRoomDdl: function () {
            var ddlRoom = $('#roomddl');
            var ddlRateType = $('#rateTypeDdl');
            var roomData = pmsSession.GetItem("roomdata");
            if (!ddlRoom || !ddlRateType || !roomData) return;

            var rooms = $.parseJSON(roomData);
            if (!rooms || rooms.length <= 0) return;

            ddlRoom.empty();
            ddlRoom.append(new Option("Select Room", "-1"));
            var rateTypeId = parseInt(ddlRateType.val());
            if (rateTypeId > -1) {
                for (var i = 0; i < rooms.length; i++) {
                    if (rooms[i].RateType.Id !== rateTypeId) continue;

                    ddlRoom.append(new Option(rooms[i].Number, rooms[i].Id));
                }
            }
        },

        BindRoomTypeDdl: function () {
            var ddlRoomType = $('#roomTypeDdl');
            var roomTypeData = pmsSession.GetItem("roomtypedata");
            if (!ddlRoomType || !roomTypeData) return;

            var roomTypes = $.parseJSON(roomTypeData);
            if (!roomTypes || roomTypes.length <= 0) return;

            ddlRoomType.empty();
            ddlRoomType.append(new Option("Select Type", "-1"));
            for (var i = 0; i < roomTypes.length; i++) {
                ddlRoomType.append(new Option(roomTypes[i].Name, roomTypes[i].Id));
            }
        },

        BindRateTypeDdl: function () {
            var ddlRateType = $('#rateTypeDdl');
            var ddlRoomType = $('#roomTypeDdl');
            var rateTypeData = pmsSession.GetItem("roomratetypedata");
            if (!ddlRateType || !ddlRoomType || !rateTypeData) return;

            var rateTypes = $.parseJSON(rateTypeData);
            if (!rateTypes || rateTypes.length <= 0) return;

            ddlRateType.empty();
            ddlRateType.append(new Option("Select Type", "-1"));
            var roomTypeId = parseInt(ddlRoomType.val());
            if (roomTypeId > -1) {
                for (var i = 0; i < rateTypes.length; i++) {
                    if (rateTypes[i].RoomTypeId !== roomTypeId) continue;

                    ddlRateType.append(new Option(rateTypes[i].Name, rateTypes[i].Id));
                }
            }
        }
    };

    function getRoomTypes() {
        args.propertyId = window.GuestCheckinManager.GetPropertyId();
        var roomTypeData = pmsSession.GetItem("roomtypedata");
        if (!roomTypeData) {
            // get room types by api calling  
            pmsService.GetRoomTypeByProperty(args);
        } else {
            window.GuestCheckinManager.BindRoomTypeDdl();
        }
    }

    function getRoomRateTypes() {
        args.propertyId = window.GuestCheckinManager.GetPropertyId();
        var roomRateTypeData = pmsSession.GetItem("roomratetypedata");
        if (!roomRateTypeData) {
            // get room rate types by api calling  
            pmsService.GetRateTypeByProperty(args);
        }
    }
    
    function getRooms(){
        args.propertyId = window.GuestCheckinManager.GetPropertyId();
        var roomData = pmsSession.GetItem("roomdata");
        if (!roomData) {
            // get room by api calling  
            pmsService.GetRoomByProperty(args);
        }
    }

    function ajaxHandlers() {

        // ajax handlers start

        pmsService.Handlers.OnGetRoomTypeByPropertySuccess = function (data) {
            //storing room type data into session storage
            pmsSession.SetItem("roomtypedata", JSON.stringify(data.RoomTypes));
            window.GuestCheckinManager.BindRoomTypeDdl();
        };
        pmsService.Handlers.OnGetRoomTypeByPropertyFailure = function () {
            // show error log
            console.log("Get Room type call failed");
        };

        pmsService.Handlers.OnGetRateTypeByPropertySuccess = function (data) {
            //storing room rate type data into session storage
            pmsSession.SetItem("roomratetypedata", JSON.stringify(data.RateTypes));
        };
        pmsService.Handlers.OnGetRateTypeByPropertyFailure = function () {
            // show error log
            console.log("Get Room rate type call failed");
        };
        
        pmsService.Handlers.OnGetRoomByPropertySuccess = function (data) {
            //storing room data into session storage
            pmsSession.SetItem("roomdata", JSON.stringify(data.Rooms));
        };
        pmsService.Handlers.OnGetRoomByPropertyFailure = function () {
            // show error log
            console.log("Get Room call failed");
        };

        // ajax handlers end
    }

    win.GuestCheckinManager = guestCheckinManager;
}(window));
