(function (win) {
    var pmsService = new window.PmsService();
    var pmsSession = window.PmsSession;
    var args = {};
    var isDdlCountryChange = null;
    var InvoiceData = {};
    var guestCheckinManager = {
        
        Initialize: function () {                       
            ajaxHandlers();
            getRoomTypes();
            getRoomRateTypes();
            getCountry();
            getAllGuest();
            //TODO: call getPaymentCharge on demand
            getPaymentCharges();
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
                    if (rooms[i].RoomType.Id !== roomTypeId || rooms[i].RoomStatus.Name.toLowerCase() === 'booked') continue;

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

        BindStateDdl: function (idx, ddlCountryChange) {

            var ddlCountry = ddlCountryChange ? $('#ddlCountry') : $('#ddlIdCountry');
            var ddlState = ddlCountryChange ? $('#ddlState') : $('#ddlIdState');
            var stateData = pmsSession.GetItem("statedata");
            if (!ddlCountry || !ddlState  || !stateData) return;

            var stateSessionData = $.parseJSON(stateData);
            if (!stateSessionData || stateSessionData.length <= 0) return;
            var stateValue = stateSessionData[idx].statevalue;

            ddlState.empty();
            ddlState.append(new Option("Select State", "-1"));
            for (var i = 0; i < stateValue.length; i++) {
                ddlState.append(new Option(stateValue[i].Name, stateValue[i].ID));
            }
        },

        BindCityDdl: function (idx) {

            var ddlState = $('#ddlState');
            var ddlCity = $('#ddlCity');
            var cityData = pmsSession.GetItem("citydata");
            if (!ddlCity || !ddlState || !cityData) return;

            var citySessionData = $.parseJSON(cityData);
            if (!citySessionData || citySessionData.length <= 0) return;
            var cityValue = citySessionData[idx].cityvalue;

            ddlCity.empty();
            ddlCity.append(new Option("Select City", "-1"));
            for (var i = 0; i < cityValue.length; i++) {
                ddlCity.append(new Option(cityValue[i].Name, cityValue[i].Id));
            }
        },

        BindCountryDdl: function () {
            var ddlCountry = $('#ddlCountry');
            var ddlIdCountry = $('#ddlIdCountry');
            var countryData = pmsSession.GetItem("countrydata");
            if (!ddlIdCountry || !ddlCountry || !countryData) return;

            var country = $.parseJSON(countryData);
            if (!country || country.length <= 0) return;

            ddlCountry.empty();
            ddlIdCountry.empty();
            ddlCountry.append(new Option("Select Country", "-1"));
            ddlIdCountry.append(new Option("Select Country", "-1"));
            for (var i = 0; i < country.length; i++) {
                ddlCountry.append(new Option(country[i].Name, country[i].Id));
                ddlIdCountry.append(new Option(country[i].Name, country[i].Id));
            }
        },

        AddBooking: function (status) {

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
            booking.Status = status;
            booking.IsActive = true;
            booking.ISHOURLYCHECKIN = $('#hourCheckin')[0].checked ? true : false;
            var noOfHours = $('#hoursComboBox').val();
            booking.HOURSTOSTAY = $('#hourCheckin')[0].checked && parseInt(noOfHours) > 0 ? parseInt(noOfHours) : 0;
            //TODO : remove hardcoded value
            booking.CreatedBy = "vipul";
            // for new booking Id = -1 
            booking.Id = -1

            booking.Invoice = prepareInvoiceDto();
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
        },
        
        GetGuestHistory: function () {
            args.guestId = $('#hdnGuestId').val() == '' ? -1 : $('#hdnGuestId').val();
            if (args.guestId != -1) {

                var guestData = pmsSession.GetItem("guesthistory");
                if (!guestData) {
                    pmsService.GetGuestHistoryById(args);
                    return;
                }
                var guestSessionData = $.parseJSON(guestData);
                if (!guestSessionData || guestSessionData.length <= 0) return;
                var idx = gcm.CheckIfKeyPresent(args.guestId, guestSessionData);
                // guestid does not exists in session then call api 
                if (idx < 0) {
                    pmsService.GetGuestHistoryById(args);
                    return;
                }
                
                // when guest id already in session
                var guestHistoryResponseDto = {};
                guestHistoryResponseDto.GuestHistory = {};
                guestHistoryResponseDto.GuestHistory = guestSessionData[idx].guesthistory;

                bindGuestHistory(guestHistoryResponseDto);
            }
        },

        GetStateByCountry: function (ddlCountryChange) {
            isDdlCountryChange = ddlCountryChange
            args.Id = isDdlCountryChange ? $('#ddlCountry').val() : $('#ddlIdCountry').val();
            // get state by api calling  
            pmsService.GetStateByCountry(args);
        },

        GetCityByState: function () {
            args.Id = $('#ddlState').val();
            // get city by api calling  
            pmsService.GetCityByState(args);
        },

        CheckIfKeyPresent: function (key, object) {
            var idx = -1;
            var found = false;
            if (object.length <= 0) return idx;

            for (var i = 0; i < object.length; i++) {
                if (!object[i] || !object[i].Id || object[i].Id !== key) continue;
                idx = i;
                break;
            }
            return idx;
        },

        SearchGuest: function () {
            var data = $.parseJSON(pmsSession.GetItem("guestinfo"));
            // if no guest info found in session storage then return null
            if (!data || data.length <= 0) return data;
            var filterGuestdata = [];
            var searchText = $('#searchGuest').val().toLowerCase();
            // if already autocomplete is performed
            if (searchText.indexOf(',') > 0) {
                searchText = searchText.split(',')[0];
            }

            for (var i = 0; i < data.length; i++) {
                // lookup for fname,lname,guestid,email,mobile#
                if (!data[i] || (data[i].FirstName.toLowerCase().indexOf(searchText) < 0
                    && data[i].LastName.toLowerCase().indexOf(searchText) < 0
                    && data[i].EmailAddress.toLowerCase().indexOf(searchText) < 0
                    && data[i].MobileNumber.toString().indexOf(searchText) < 0)){

                    if (!data[i] || !data[i].GuestMappings || data[i].GuestMappings.length <= 0) continue;
                    // look up for guest id number
                    for (var j = 0; j < data[i].GuestMappings.length; j++) {
                        if (!data[i].GuestMappings[j].IDDETAILS
                        || data[i].GuestMappings[j].IDDETAILS.toLowerCase().indexOf(searchText) < 0) continue;

                        if (data[i]) {
                            filterGuestdata.push(data[i]);
                        }
                    }
                   
                } else {
                    if (data[i]) {
                        filterGuestdata.push(data[i]);
                    }
                }
            }

            if (filterGuestdata.length <= 0) {
                $('#fName').val('');
                $('#lName').val('');
                $('#phone').val('');
                $('#email').val('');
                $('#hdnGuestId').val('');
                $('#idDetails').val('');
                // clear guest history if guest id is not present
                window.GuestCheckinManager.AutoCollapseGuestHistory();
            }
            return filterGuestdata;
        },

        AutoCollapseGuestHistory: function () {
            $('#divHistory').html('');
            $('#history').attr('aria-expanded', "false");
            $("#history").attr("class", "collapsed");
            $('#collapse1').attr('aria-expanded', "false");
            $("#collapse1").attr("class", "panel-collapse collapse");
        },
        
        PopulateCharges: function (data) {
            var divInvoice = $('#divInvoice');
            var invoiceTemplate = $('#invoiceTemplate');
            data = appendTotalRoomCharge(data)
            divInvoice.html(invoiceTemplate.render(data));
            window.GuestCheckinManager.CalculateTotalCharge();
        },

        IsNumeric: function (e) {
            if (e.shiftKey || e.ctrlKey || e.altKey) {
                e.preventDefault();
                return false;
            } else {
                var key = e.keyCode;
                if (!((key == 8) || (key == 46) || (key >= 35 && key <= 40) || (key >= 48 && key <= 57) || (key >= 96 && key <= 105))) {
                    e.preventDefault();
                    return false;
                }
            }
            return true;
        },

        CalculateTotalCharge: function () {
            var totalCharge = 0;
            var stayDays = window.GuestCheckinManager.InvoiceData.StayDays;
            var baseRoomCharge = $('#baseRoomCharge');
            var totalRoomCharge = $('#totalRoomCharge');
            var htmlElementCol = $("input[id*='taxVal']");

            //  other tax charges calulations
            if (htmlElementCol && htmlElementCol.length > 0) {
                for (var i = 0; i < htmlElementCol.length; i++) {
                    if (!htmlElementCol[i] || !htmlElementCol[i].value || isNaN(htmlElementCol[i].value)) continue;
                    totalCharge = (parseFloat(totalCharge) + parseFloat(htmlElementCol[i].value, 10)).toFixed(2);
                }
            }
            
            //  room base charge calulations
            var baseCharge = baseRoomCharge && baseRoomCharge.val() && !isNaN(baseRoomCharge.val()) ? parseFloat(baseRoomCharge.val(), 10).toFixed(2) : 0;
            if (totalRoomCharge) {
                totalRoomCharge.val(parseFloat(baseCharge).toFixed(2) * stayDays);
            }
            
            //  total room charge calulations
            if (totalRoomCharge && totalRoomCharge.val() && !isNaN(totalRoomCharge.val())) {
                totalCharge = (parseFloat(totalCharge) + parseFloat(totalRoomCharge.val(), 10)).toFixed(2);
            }

            totalCharge = applyDiscount(totalCharge);

            $('#total')[0].innerText = totalCharge;
            return totalCharge;
        }
        
        //DateDiff: function () {
        //    //var dateFrom = $('#dateFrom').val();
        //    //var dateTo = $('#dateTo').val();
        //    //alert(dateFrom);

        //    var start_actual_time = "01/17/2012 11:20";
        //    var end_actual_time = "01/18/2012 12:25";

        //    start_actual_time = new Date(start_actual_time);
        //    end_actual_time = new Date(end_actual_time);

        //    var diff = end_actual_time - start_actual_time;

        //    var diffSeconds = diff / 1000;
        //    var HH = Math.floor(diffSeconds / 3600);
        //    var MM = Math.floor(diffSeconds % 3600) / 60;
        //    alert(HH);

        //}
    };
    
    function applyDiscount(totalCharge) {
        if (!totalCharge || isNaN(totalCharge)) return 0;
        var discount = $('#discount')[0].value;
        discount = !discount || isNaN(discount) ? 0 : parseFloat(discount, 10).toFixed(2);
        totalCharge = (parseFloat(totalCharge) - parseFloat(discount)).toFixed(2);
        return totalCharge;    
    }

    function appendTotalRoomCharge(data) {
        if (!data) return data;
        var tax = {}; 
        tax.TaxName = 'Total Room Charge';
        tax.IsEnabled = false;
        data.Tax.push(tax);
        return data;
    }

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
        address.IsActive = true;
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
        
        guest.IsActive = true;
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
        guestMapping.IsActive = true;
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
        //TODO:reading additional guest info from grid 
        additionalGuest.FirstName = $('#adFName').val();
        additionalGuest.LastName = $('#adLName').val();
        additionalGuest.IsActive = true;
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
    
    function prepareInvoiceDto() {

        var invoice = {};
        invoice.InvoiceTaxDetails = [];
        invoice.InvoiceItem = [];
        invoice.InvoicePaymentDetail = [];

        var htmlElementCol = $("input[id*='taxVal']");
        if (!htmlElementCol || htmlElementCol.length <= 0) return invoice;
        for (var i = 0; i < htmlElementCol.length; i++) {
            if (!htmlElementCol[i] || !htmlElementCol[i].name) continue;
            var tax = {};
            var taxName = htmlElementCol[i].name;
            var taxValue = !htmlElementCol[i].value || isNaN(htmlElementCol[i].value) ? 0 : parseFloat(htmlElementCol[i].value, 10).toFixed(2);
            tax.TaxShortName = taxName;
            tax.TaxAmount = taxValue;
            invoice.InvoiceTaxDetails.push(tax);
        }

        // for new booking id = -1
        invoice.BookingID = -1;
        invoice.GuestID = $('#hdnGuestId').val() == '' ? -1 : $('#hdnGuestId').val();
        invoice.ID = -1;
        invoice.CreatedOn = getCurrentDate();
        invoice.IsActive = true;

        //TODO : remove hardcoded value
        invoice.CreatedBy = "vipul";

        return invoice;
        //TODO add additional tax info
        //$('#total')[0].innerText = totalCharge;
        //discount
        //dynamic field
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
        roomBooking.IsActive = true;

        //TODO : remove hardcoded value
        roomBooking.CreatedBy = "vipul";
        roomBooking.IsExtra = false;

        roomBookings.push(roomBooking);
        return roomBookings;
    }

    function getRoomTypes() {
        args.propertyId = pmsSession.GetItem("propertyid");
        var roomTypeData = pmsSession.GetItem("roomtypedata");
        if (!roomTypeData) {
            // get room types by api calling  
            pmsService.GetRoomTypeByProperty(args);
        } else {
            window.GuestCheckinManager.BindRoomTypeDdl();
        }
    }
        
    function getAllGuest() {
        var guestData = pmsSession.GetItem("guestinfo");
        if (!guestData) {
            // get guest by api calling  
            pmsService.GetGuest(args);
        }
    }

    function getPaymentCharges() {
        // get paymentCharge details by api calling 
        var paymentChargeRequestDto = {};
        paymentChargeRequestDto.PropertyId = pmsSession.GetItem("propertyid");
        
        var dateFrom = $('#dateFrom').val();
        var dateTo = $('#dateTo').val();
        var roomType = $('#roomTypeDdl').val();
        var rateType = $('#rateTypeDdl').val();
        var noOfHours = $('#hoursComboBox').val();
        
        // TODO: remove hardcoded value
        dateFrom = "06/12/2017 12:00 am";
        dateTo = "06/16/2017 2:00 am";
        roomType = 1;
        rateType = 1;

        // check checkin date 
        if (!dateFrom || dateFrom.length <= 0) {
            alert("Please select checkin date");
            $('#dateFrom').focus();
            return false;
        }

        // check checkout date 
        if (!dateTo || dateTo.length <= 0) {
            alert("Please select checkout date");
            $('#dateTo').focus();
            return false;
        }

        if (!roomType || roomType === '-1') {
            alert("Select proper room type");
            return false;
        }

        if (!rateType || rateType === '-1') {
            alert("Select proper rate type");
            return false;
        }

        if ($('#hourCheckin')[0].checked && noOfHours === '-1') {
            alert("Please select proper checkout hours");
            return false;
        }

        paymentChargeRequestDto.CheckinTime = dateFrom;
        paymentChargeRequestDto.CheckoutTime = dateTo;
        paymentChargeRequestDto.RoomTypeId = roomType
        paymentChargeRequestDto.RateTypeId = rateType
        paymentChargeRequestDto.IsHourly = $('#hourCheckin')[0].checked ? true : false;
        paymentChargeRequestDto.NoOfHours = $('#hourCheckin')[0].checked && parseInt(noOfHours) > 0 ? parseInt(noOfHours) : 0;
        
        pmsService.GetPaymentCharges(paymentChargeRequestDto);
    }    

    function getCountry() {
        var countryData = pmsSession.GetItem("countrydata");
        if (!countryData) {
            // get country by api calling  
            pmsService.GetCountry(args);
        } else {
            window.GuestCheckinManager.BindCountryDdl();
        }
    }

    function getRoomRateTypes() {
        args.propertyId = pmsSession.GetItem("propertyid");
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
    //    args.propertyId = pmsSession.GetItem("propertyid");
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
        var noOfHours = $('#hoursComboBox').val();
        var baseRoomCharge = $("#baseRoomCharge");
        var totalRoomCharge = $('#totalRoomCharge');
        
        if (!baseRoomCharge || baseRoomCharge.val() <= 0) {
            alert('Enter valid base room charge.');
            baseRoomCharge.focus();
            return false;
        }

        if (!totalRoomCharge || totalRoomCharge.val() <= 0) {
            alert('please verify total room charge.');
            totalRoomCharge.focus();
            return false;
        }

        if ($('#hourCheckin')[0].checked && noOfHours === '-1') {
            alert("Please select proper checkout hours");
            return false;
        }
        
        // check checkin date 
        if (!dateFrom || dateFrom.length <= 0) {
            alert("Please select checkin date");
            $('#dateFrom').focus();
            return false;
        }

        // check checkout date 
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
        var validEmailIdRegex = new RegExp(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
        // check email 
        if (emailId && emailId.length > 0) {
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
        $("#searchGuest").val('');
        $('#hdnGuestId').val('');
        $('#idDetails').val('');
        window.GuestCheckinManager.AutoCollapseGuestHistory();
    }

    function bindGuestHistory(data){
        var divHistory = $('#divHistory');
        var historyTemplate = $('#historyTemplate');
        divHistory.html(historyTemplate.render(data));
    }    
        
    function uploadImage(source) {
        if (window.FormData !== undefined) {
            // if success upload image of guest
            var data = new FormData();
            var files = source.get(0).files;
            // Add the uploaded image content to the form data collection
            if (files.length > 0) {
                data.append("UploadedImage", files[0]);
                pmsService.ImageUpload(data);
            }
        }
    }
    
    function ajaxHandlers() {

        // ajax handlers start

        pmsService.Handlers.OnAddBookingSuccess = function (data) {
            var status = data.StatusDescription.toLowerCase();
            if (status.indexOf("successfully") >= 0) {
                // clearAllFields();
                var roomnumber = $('#roomddl').val();
                var fname = $('#fName').val();
                var lname = $('#lName').val();
                var initials = $('#ddlInitials')[0].selectedOptions[0].innerText;
                var message = 'Roomnumber' + roomnumber + ' has been booked for ' + initials + ' ' + fname + ' ' + lname;
                alert(message);
                console.log(message);
                // if booking is successful then upload image
                uploadImage($("#uploadPhoto"));
                // clear guesthistory from session storage
                pmsSession.RemoveItem("guesthistory");
            } else {
                console.error(status);
                alert(status);
            }            
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

        pmsService.Handlers.OnGetGuestHistoryByIdSuccess = function (data) {
            if (!data || !data.GuestHistory || data.GuestHistory.length <= 0) return;

            var guestId = $('#hdnGuestId').val();
            var idx = gcm.CheckIfKeyPresent(guestId, pmsSession.GuestSessionKey);
            // store guesthistory data in session storage only when guestid is not present in session
            if (idx === -1) {
                pmsSession.GuestSessionKey.push({
                    Id: guestId,
                    guesthistory: data.GuestHistory
                });
                pmsSession.SetItem("guesthistory", JSON.stringify(pmsSession.GuestSessionKey));
            }
            bindGuestHistory(data);
        };
        pmsService.Handlers.OnGetGuestHistoryByIdFailure = function () {
            // show error log
            console.error("Guest History failed");
        };

        pmsService.Handlers.OnGetCountrySuccess = function (data) {
            if (!data || !data.Country || data.Country.length <= 0) return;

            pmsSession.SetItem("countrydata", JSON.stringify(data.Country));
            window.GuestCheckinManager.BindCountryDdl();
        };
        pmsService.Handlers.OnGetCountryFailure = function () {
            // show error log
            console.error("get country call failed");
        };

        pmsService.Handlers.OnGetStateByCountrySuccess = function (data) {
            if (!data || !data.States || data.States.length <= 0) return;
            
            var countryId = isDdlCountryChange ? $('#ddlCountry').val() : $('#ddlIdCountry').val();
            
            var idx = gcm.CheckIfKeyPresent(countryId, pmsSession.CountrySessionKey);
            // store state data in session storage only when country key is not present
            if (idx === -1) {
                pmsSession.CountrySessionKey.push({
                    Id: countryId,
                    statevalue: data.States
                });
                pmsSession.SetItem("statedata", JSON.stringify(pmsSession.CountrySessionKey));
                //calculating the index of the statedata added in session above
                idx = pmsSession.CountrySessionKey.length - 1;
            }
            
            window.GuestCheckinManager.BindStateDdl(idx, isDdlCountryChange);
        };
        pmsService.Handlers.OnGetStateByCountryFailure = function () {
            // show error log
            console.error("get state call failed");
        };

        pmsService.Handlers.OnGetGuestSuccess = function (data) {
            if (!data || !data.Guest || data.Guest.length <= 0) return;
            pmsSession.SetItem("guestinfo", JSON.stringify(data.Guest));
        };
        pmsService.Handlers.OnGetGuestFailure = function () {
            // show error log
            console.error("get guest call failed");
        };

        pmsService.Handlers.OnGetCityByStateSuccess = function (data) {
            if (!data || !data.City || data.City.length <= 0) return;

            var stateId = $('#ddlState').val();

            var idx = gcm.CheckIfKeyPresent(stateId, pmsSession.StateSessionKey);
            // store city data in session storage only when state key is not present
            if (idx === -1) {
                pmsSession.StateSessionKey.push({
                    Id: stateId,
                    cityvalue: data.City
                });
                pmsSession.SetItem("citydata", JSON.stringify(pmsSession.StateSessionKey));
                //calculating the index of the citydata added in session above
                idx = pmsSession.StateSessionKey.length - 1;
            }

            window.GuestCheckinManager.BindCityDdl(idx);
        };
        pmsService.Handlers.OnGetCityByStateFailure = function () {
            // show error log
            console.error("get city call failed");
        };

        pmsService.Handlers.OnGetPaymentChargesSuccess = function (data) {
            if (!data || !data.Tax || data.Tax.length <= 0) return;
            window.GuestCheckinManager.InvoiceData = data;
            window.GuestCheckinManager.PopulateCharges(data);
        };
        pmsService.Handlers.OnGetPaymentChargesFailure = function () {
            // show error log
            console.error("get PaymentCharges call failed");
        };

        // ajax handlers end
    }

    win.GuestCheckinManager = guestCheckinManager;
}(window));
