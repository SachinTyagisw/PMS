(function (win) {

    var propertyId = null;
    var pmsService = new window.PmsService();
    var pmsSession = window.PmsSession;
    var args = {};
    var guestCheckinManager = {
        
        Initialize: function () {                       

            ajaxHandlers();
            getRoomTypes();
            getRooms();
        },

        SetPropertyId: function (id) {
            this.propertyId = id;
        },

        GetPropertyId: function () {
            return this.propertyId;
        },

        BindRoomDdl: function (roomRateId) {
            var ddlRoomId = $('#roomddl');
            var roomData = pmsSession.GetItem("roomdata");
            var rooms = $.parseJSON(roomData);
        },

        BindRoomTypeDdl: function () {
            var ddlRoomTypeId = $('#roomTypeDdl');
            var roomTypeData = pmsSession.GetItem("roomtypedata");
            if (!ddlRoomTypeId || !roomTypeData) return;

            var roomTypes = $.parseJSON(roomTypeData);
            if (!roomTypes || roomTypes.length <= 0) return;

            ddlRoomTypeId.empty();
            //ddlRoomTypeId.append(new Option("Select Roomtype", "-1"));
            for (var i = 0; i < roomTypes.length; i++) {
                ddlRoomTypeId.append(new Option(roomTypes[i].Name, roomTypes[i].Id));
            }
        },        
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
