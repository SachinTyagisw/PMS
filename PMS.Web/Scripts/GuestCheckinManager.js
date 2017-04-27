(function (win) {

    var propertyId = null;
    var guestCheckinManager = {

        SetPropertyId: function (id) {
            this.propertyId = id;
        },

        GetPropertyId: function () {
            return this.propertyId;
        },

        Initialize: function () {
            var pmsService = new window.PmsService();            
            var args = {};
            args.propertyId = this.GetPropertyId();

            // getting room data
            var data = pmsService.GetRoomByProperty(args);

            pmsService.Handlers.OnGetRoomByPropertySuccess = function (data) {
                window.PmsSession.SetItem("Roomdata", JSON.stringify(data.Rooms));
            };
            pmsService.Handlers.OnGetRoomByPropertyFailure = function () {

            };
        }        
    };

    win.GuestCheckinManager = guestCheckinManager;
}(window));
