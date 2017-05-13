(function (win) {
    var pmsService = new window.PmsService();
    var pmsSession = window.PmsSession;
    var args = {};    
    var guestCheckinManager = {
        
        Initialize: function () {                       
            ajaxHandlers();
            getRoomTypes();
            getRoomRateTypes();
            //getRooms();
        },

        ShouldCallGetRoomApi: function () {
            var roomTypeId = $('#roomTypeDdl').val();
            var dtFrom = $("#dateFrom").val();
            var dtTo = $("#dateTo").val();

            if (!roomTypeId || !dtFrom || !dtTo
                || roomTypeId === -1 || dtFrom.length <= 0 || dtTo.length <= 0) {
                return false;
            }
            return true;
        },

        BindRoomDdl: function () {
            var ddlRoom = $('#roomddl');
            var ddlRoomType = $('#roomTypeDdl');
            var roomData = pmsSession.GetItem("roomdata");
            if (!ddlRoom || !ddlRoomType || !roomData) return;

            var rooms = $.parseJSON(roomData);
            if (!rooms || rooms.length <= 0) return;

            ddlRoom.empty();
            ddlRoom.append(new Option("Select Room", "-1"));
            var roomTypeId = parseInt(ddlRoomType.val());
            if (roomTypeId > -1) {
                for (var i = 0; i < rooms.length; i++) {
                    if (rooms[i].RoomType.Id !== roomTypeId || rooms[i].RoomStatus.Name === 'BOOKED') continue;

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
            var rateTypeData = pmsSession.GetItem("ratetypedata");
            if (!ddlRateType || !rateTypeData) return;

            var rateTypes = $.parseJSON(rateTypeData);
            if (!rateTypes || rateTypes.length <= 0) return;

            ddlRateType.empty();
            ddlRateType.append(new Option("Select Type", "-1"));
            for (var i = 0; i < rateTypes.length; i++) {
                ddlRateType.append(new Option(rateTypes[i].Name, rateTypes[i].Id));
            }
        },       

        AddBooking: function () {

            if (!validateInputs()) return;

            var bookingRequestDto = {};
            bookingRequestDto.Booking = {};
            var booking = {};           

            booking.CheckinTime = $('#dateFrom').val();
            booking.CheckoutTime = $('#dateTo').val();
            booking.NoOfAdult = $('#ddlAdults').val();
            booking.NoOfChild = $('#ddlChild').val();
            booking.PropertyId = pmsSession.GetItem("propertyid");
            booking.GuestRemarks = $('#guestComments').val();
            booking.TransactionRemarks = $('#transRemarks').val();
            booking.CreatedOn = getCurrentDate();
            booking.Status = "Confirmed";
            //TODO : remove hardcoded value
            booking.CreatedBy = "vipul";
            // for new booking Id = -1 
            booking.Id = -1

            booking.RoomBookings = prepareRoomBookingDto();
            booking.Guests = prepareGuestDto();
            booking.GuestMappings = prepareGuestIdDto();
            booking.Addresses = prepareAddressDto();
            booking.AdditionalGuests = prepareAdditionalGuestDto();
            
            if (!booking.RoomBookings || !booking.Guests || !booking.Addresses) {
                console.error('Room Booking can not be done.');
                alert("Room Booking can not be done.");
                return;
            }

            bookingRequestDto.Booking = booking;
            // add booking by api calling  
            pmsService.AddBooking(bookingRequestDto);           
        },

        GetRoomByDate: function () {
            var getRoomByDateRequestDto = {};
            getRoomByDateRequestDto.CheckinDate = $('#dateFrom').val();
            getRoomByDateRequestDto.CheckoutDate = $('#dateTo').val();
            getRoomByDateRequestDto.PropertyId = pmsSession.GetItem("propertyid");

            // get room by api calling  
            pmsService.GetRoomByDate(getRoomByDateRequestDto);
        }
    };
    
    function prepareAddressDto() {
        var addresses = [];
        var address = {};

        address.Id = -1;
        address.City = $('#ddlCity').val();
        address.State = $('#ddlState').val();
        address.Country = $('#ddlCountry').val();
        address.ZipCode = $('#zipCode').val();
        address.Address1 = $('#address').val();
        //TODO : update with address2 field
        address.Address2 = $('#address').val();
        address.GuestID = $('#hdnGuestId').val() == '' ? -1 : $('#hdnGuestId').val();
        address.CreatedOn = getCurrentDate();
        //TODO : remove hardcoded value
        address.CreatedBy = "vipul";
        //TODO: addresstype to be selected from address type ddl
        address.AddressTypeID = 1;
        
        addresses.push(address);
        return addresses;
    }
        
    function prepareGuestDto() {
        var guests = [];
        var guest = {};
        
        // for new guest guestid should be -1 else guestid
        guest.Id = $('#hdnGuestId').val() == '' ? -1 : $('#hdnGuestId').val();
        guest.FirstName = $('#fName').val();
        guest.LastName = $('#lName').val();
        guest.MobileNumber = $('#phone').val();
        guest.EmailAddress = $('#email').val();
        guest.DOB = $('#dob').val();
        guest.Gender = $('#ddlInitials').val();

        var files = $("#uploadPhoto").get(0).files;
        if (files.length > 0) {
            guest.PhotoPath = "D:\\PMSHosted\\PMSApi\\UploadedFiles\\" + files[0].name;
        } else {
            guest.PhotoPath = "No Image Available";
        }
        
        guest.CreatedOn = getCurrentDate();
        //TODO : remove hardcoded value
        guest.CreatedBy = "vipul";        

        guests.push(guest);
        return guests;
    }

    function prepareGuestIdDto() {
        var guestMapping = {};
        var guestMappings = [];

        guestMapping.Id = "-1"
        guestMapping.GUESTID = $('#hdnGuestId').val() == '' ? -1 : $('#hdnGuestId').val();
        guestMapping.IDTYPEID = $('#ddlIdType').val();
        guestMapping.IDDETAILS = $('#idDetails').val();
        guestMapping.IdExpiryDate = $('#idExpiry').val();
        guestMapping.IdIssueState = $('#ddlIdState').val();
        guestMapping.IdIssueCountry = $('#ddlIdCountry').val();
        guestMapping.CreatedOn = getCurrentDate();
        //TODO : remove hardcoded value
        guestMapping.CreatedBy = "vipul";        
        
        guestMappings.push(guestMapping);
        return guestMappings;
    }

    function prepareAdditionalGuestDto() {
        var additionalGuest = {};
        var additionalGuests = [];

        additionalGuest.Id = -1;
        additionalGuest.BookingId = -1;
        //TODO:reading additonal guest info from grid 
        additionalGuest.FirstName = $('#adFName').val();
        additionalGuest.LastName = $('#adLName').val();

        //TODO: get value from new upload
        var files = $("#uploadPhoto").get(0).files;
        if (files.length > 0) {
            additionalGuest.GUESTIDPath = "D:\\PMSHosted\\PMSApi\\UploadedFiles\\" + files[0].name;
        } else {
            additionalGuest.GUESTIDPath = "No Image Available";
        }

        //TODO: get value from initial selection eg: mr,ms,mrs
        additionalGuest.Gender = "M";
        additionalGuest.CreatedOn = getCurrentDate();

        //TODO : remove hardcoded value
        additionalGuest.CreatedBy = "vipul";

        additionalGuests.push(additionalGuest);
        return additionalGuests;
    }

    function prepareRoomBookingDto() {
        var roomBookings = [];
        var roomBooking = {};
        var roomType = $('#roomTypeDdl').val();
        roomBooking.RoomId = $('#roomddl').val();      
        roomBooking.GuestID = $('#hdnGuestId').val() == '' ? -1 : $('#hdnGuestId').val();
        // for new booking id = -1
        roomBooking.BookingId = -1
        roomBooking.Id = -1
        roomBooking.CreatedOn = getCurrentDate();

        //TODO : remove hardcoded value
        roomBooking.CreatedBy = "vipul";
        roomBooking.IsExtra = false;
        roomBooking.Discount = 2.0;
        roomBooking.RoomCharges = 12.0;

        roomBookings.push(roomBooking);
        return roomBookings;
    }

    function getRoomTypes() {
        args.propertyId = pmsSession.GetItem("propertyid");;
        var roomTypeData = pmsSession.GetItem("roomtypedata");
        if (!roomTypeData) {
            // get room types by api calling  
            pmsService.GetRoomTypeByProperty(args);
        } else {
            window.GuestCheckinManager.BindRoomTypeDdl();
        }
    }

    function getRoomRateTypes() {
        args.propertyId = pmsSession.GetItem("propertyid");;
        var rateTypeData = pmsSession.GetItem("ratetypedata");
        if (!rateTypeData) {
            // get room rate types by api calling  
            pmsService.GetRateTypeByProperty(args);
        }
        else {
            window.GuestCheckinManager.BindRateTypeDdl();
        }
    }
    
    //function getRooms(){
    //    args.propertyId = pmsSession.GetItem("propertyid");;
    //    var roomData = pmsSession.GetItem("roomdata");
    //    if (!roomData) {
    //        // get room by api calling  
    //        pmsService.GetRoomByProperty(args);
    //    }
    //}     

    function getCurrentDate() {
        // date format yyyy/mm/dd
        var dt = new Date();
        var month = dt.getMonth() + 1;
        var day = dt.getDate();
        var dateOutput = dt.getFullYear() + '/' +
            (month < 10 ? '0' : '') + month + '/' +
            (day < 10 ? '0' : '') + day;

        var time = dt.getHours() + ":" + dt.getMinutes() + ":" + dt.getSeconds();
        return dateOutput + ' ' + time;
    }

    function validateInputs() {
        var fname = $("#fName").val();
        var lname = $("#lName").val();
        var phNumber = $("#phone").val();
        var zipCode = $("#zipCode").val();
        var idDetails = $("#idDetails").val();
        var idExpiry = $("#idExpiry").val();
        var dateFrom = $("#dateFrom").val();
        var dateTo = $("#dateTo").val();
        var adult = $("#ddlAdults").val();
        var child = $("#ddlChild").val();
        var guestIdType = $("#ddlIdType").val();
        var roomType = $('#roomTypeDdl').val();
        var roomId = $('#roomddl').val();
        var city = $('#ddlCity').val();
        var state = $('#ddlState').val();
        var country = $('#ddlCountry').val();

        // check checkin date 
        if (!dateFrom || dateFrom.length <= 0) {
            alert("Please select checkin date");
            $('#dateFrom').focus();
            return false;
        }

        // check checkin date 
        if (!dateTo || dateTo.length <= 0) {
            alert("Please select checkout date");
            $('#dateTo').focus();
            return false;
        }

        if (!roomType || roomType === '-1') {
            alert("Select proper room type");
            return false;
        }

        if (!roomId || roomId === '-1') {
            alert("Select proper room number");
            return false;
        }

        // check adult or child value
        if ((!adult || adult <= 0) && (!child || child <= 0 )) {
            alert("Please select atleast an adult or child");
            return false;
        }

        // check first name 
        if (!fname || fname.length <= 0) {
            alert("Please enter the first name");
            $('#fName').focus();
            return false;
        }
        // check last name 
        if (!lname || lname.length <= 0) {
            alert("Please enter the last name");
            $('#lName').focus();
            return false;
        }
        // check phone number
        if (!phNumber || phNumber.length <= 0) {
            alert("Please enter phone number");
            $('#phone').focus();
            return false;
        }

        if (!city || city === '-1') {
            alert("Select proper city");
            return false;
        }

        if (!state || state === '-1') {
            alert("Select proper state");
            return false;
        }

        if (!country || country === '-1') {
            alert("Select proper country");
            return false;
        }

        // check zipcode
        if (!zipCode || zipCode.length <= 0) {
            alert("Please enter zip code");
            $('#zipCode').focus();
            return false;
        }

        if (!guestIdType || guestIdType === '-1') {
            alert("Guest Identification type is incorrect.");
            return false;
        }
        // check guest id details
        if (!idDetails || idDetails.length <= 0) {
            alert("Please enter guest identification number");
            $('#idDetails').focus();
            return false;
        }

        // check id expiry details 
        if (!idExpiry || idExpiry.length <= 0) {
            alert("Please enter guest ID expiry details");
            $('#idExpiry').focus();
            return false;
        }

        var emailId = $("#email").val();
        var validEmailIdRegex = new RegExp(/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/);
        /// check email 
        if (!emailId || emailId.length > 0) {
            var testemail = validEmailIdRegex.test(emailId);
            if (testemail !== true) {
                alert("Please enter valid email format.");
                $('#email').focus();
                return false;
            }             
        } else {
            alert("Please enter valid email format.");
            $('#email').focus();
            return false;
        }
        return true;
    }
    
    function clearAllFields() {
        $("#dateFrom").val('');
        $("#dateTo").val('');
        $('#roomTypeDdl').val('-1');
        $('#roomddl').empty();
    }

    function ajaxHandlers() {

        // ajax handlers start

        pmsService.Handlers.OnAddBookingSuccess = function (data) {
            if (data.StatusDescription.toLowerCase().indexOf("successfully") >= 0) {
                clearAllFields();
                console.log(data.StatusDescription);
                // if booking is successful then upload image
                if (window.FormData !== undefined) {
                    // if success upload image of guest
                    var data = new FormData();
                    var files = $("#uploadPhoto").get(0).files;
                    // Add the uploaded image content to the form data collection
                    if (files.length > 0) {
                        data.append("UploadedImage", files[0]);
                        pmsService.ImageUpload(data);
                    }
                }
            } else {
                console.error(data.StatusDescription);
            }
          
            alert(data.StatusDescription);
        };

        pmsService.Handlers.OnAddBookingFailure = function () {
            // show error log
            console.error("Room Booking is failed");
        };

        pmsService.Handlers.OnGetRoomTypeByPropertySuccess = function (data) {
            //storing room type data into session storage
            pmsSession.SetItem("roomtypedata", JSON.stringify(data.RoomTypes));
            window.GuestCheckinManager.BindRoomTypeDdl();
        };
        pmsService.Handlers.OnGetRoomTypeByPropertyFailure = function () {
            // show error log
            console.error("Get Room type call failed");
        };

        pmsService.Handlers.OnGetRateTypeByPropertySuccess = function (data) {
            //storing room rate type data into session storage
            pmsSession.SetItem("ratetypedata", JSON.stringify(data.RateTypes));
            window.GuestCheckinManager.BindRateTypeDdl();
        };
        pmsService.Handlers.OnGetRateTypeByPropertyFailure = function () {
            // show error log
            console.error("Get Room rate type call failed");
        };
        
        //pmsService.Handlers.OnGetRoomByPropertySuccess = function (data) {
        //    //storing room data into session storage
        //    pmsSession.SetItem("roomdata", JSON.stringify(data.Rooms));
        //};
        //pmsService.Handlers.OnGetRoomByPropertyFailure = function () {
        //    // show error log
        //    console.error("Get Room call failed");
        //};

        pmsService.Handlers.OnImageUploadSuccess = function (data) {
            console.log(data[0]);
        };
        pmsService.Handlers.OnImageUploadFailure = function () {
            // show error log
            console.error("Image upload failed");
        };

        pmsService.Handlers.OnGetRoomByDateSuccess = function (data) {
            pmsSession.SetItem("roomdata", JSON.stringify(data.Rooms));
            window.GuestCheckinManager.BindRoomDdl();
        };
        pmsService.Handlers.OnGetRoomByDateFailure = function () {
            // show error log
            console.error("get room call failed");
        };

        // ajax handlers end
    }

    win.GuestCheckinManager = guestCheckinManager;
}(window));
