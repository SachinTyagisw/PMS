(function (win) {

    var guestCheckinManager = {

        Initialize: function () {
            var pmsService = new window.PmsService();
            var args = {};
            args.propertyId = 1;

            // getting room data
            var data = pmsService.GetRoomByProperty(args);

            pmsService.Handlers.OnGetRoomByPropertySuccess = function (data) {

            };
            pmsService.Handlers.OnGetRoomByPropertyFailure = function () {

            };
        }
    };

    win.GuestCheckinManager = guestCheckinManager;
}(window));
