﻿(function (win) {
    var pmsService = new window.PmsService();
    var pmsSession = window.PmsSession;
    var args = {};
    var ddlCountryObj = null;
    var invoiceData = {};
    var bookingStatus = '';
    var isCheckoutDateModified = false;
    var roomSelectedFromDashBoard = -1;
    var roomIdFromDashboard = -1;
    var guestCheckinManager = {

        PropertySettingResponseDto: {
            PropertySetting: null,
            FloorSettings: null,
            RoomTypeSettings: null,
            RoomSettings: null,
            ExtraChargeSettings: null,
            PaymentTypeSettings: null,
            RateSettings: null,
            RateTypeSettings: null,
            TaxSettings: null,
            Bookings: null,
            ExpenseCategorySettings: null,
            ExpenseSettings: null,
            UserSetting: null,
            AllFunctionalitiesSettings: null,
            FunctionalitiesSettings: null,
            GuestSetting: null,
            PropertyForAccessSetting: null
        },

        BookingDto: {
            PropertyId: null,
            GuestId: null,
            BookingId: null,
            InvoiceId: null,
            RoomBookingId: null,
            GuestMappingId: null,
            AddressId: null,
            AddressTypeId: null,
            AdditionalGuestId: null
        },

        ReportDto: {
            Shifts: null,
            ConsolidatedShifts: null,
            ManagerRecords: null,
            ConsolidatedManagerRecordsYear: null,
            ConsolidatedManagerRecordsMonth: null,
            GuestSummary: null
        },
        LocalUserDto: {
            Functionalities: null
        },

        Initialize: function () {
            if (!window.PmsSession.GetItem("username")) {
                window.GuestCheckinManager.BookingDto.GuestId = null;
                window.GuestCheckinManager.BookingDto.InvoiceId = null;
                window.GuestCheckinManager.BookingDto.RoomBookingId = null;
                window.GuestCheckinManager.BookingDto.AddressId = null;
                window.GuestCheckinManager.BookingDto.AdditionalGuestId = null;
                window.GuestCheckinManager.BookingDto.GuestMappingId = null;
                window.GuestCheckinManager.BookingDto.BookingId = null;
                window.location.replace(window.webBaseUrl + "Account/Login");
                return;
            }
            getAllGuest();
            //getRooms();            
            window.GuestCheckinManager.AjaxHandlers();
        },

        BindInitDropdowns: function () {
            if (!pmsSession.GetItem("roomtypedata")) {
                window.GuestCheckinManager.GetRoomTypes();
            } else {
                var roomTypeData = window.PmsSession.GetItem("roomtypedata");
                var roomTypes = $.parseJSON(roomTypeData);
                window.GuestCheckinManager.BindRoomTypeDdl($('#roomTypeDdl'), roomTypes);
            }
            if (!pmsSession.GetItem("roomratedata")) {
                Notifications.SubscribeActive("on-roomrate-get-success", function (sender, args) {
                    window.GuestCheckinManager.BindRateTypeDdl($('#rateTypeDdl'));
                });
                window.GuestCheckinManager.GetRoomRateByProperty();
            } else {
                window.GuestCheckinManager.BindRateTypeDdl($('#rateTypeDdl'));
            }
            if ($('#ddlCountry') && $('#ddlCountry').length > 0) {
                window.GuestCheckinManager.GetCountry($('#ddlCountry'));
            }
            window.GuestCheckinManager.GetStateByCountry(-1);
            window.GuestCheckinManager.GetCityByState(-1);
        },

        GetRoomRateType: function (propertyId) {
            args.propertyId = propertyId && propertyId > 0 ? propertyId : getPropertyId();
            // get room rate types by api calling  
            pmsService.GetRateTypeByProperty(args);
        },

        GetRoomRateByProperty: function (propertyId) {
            args.propertyId = propertyId && propertyId > 0 ? propertyId : getPropertyId();
            // get room rate by api calling  
            pmsService.GetRoomRateByProperty(args);
        },

        ShouldCallGetRoomApi: function () {
            var roomTypeId = $('#roomTypeDdl').val();
            var dtFrom = $("#dateFrom").val();
            var dtTo = $("#dateTo").val();

            if (!roomTypeId || !dtFrom || !dtTo ||
                parseInt(roomTypeId) <= -1 || dtFrom.length <= 0 || dtTo.length <= 0) {
                return false;
            }
            return true;
        },

        ToggleInvoiceWarning: function (htmlElement, shouldShow) {
            if (shouldShow) {
                htmlElement[0].style = 'display: block;color: red;';
                return;
            }
            htmlElement[0].style = 'display:none';
            return;
        },

        ShouldShowLoadInvoiceWarning: function () {
            var dateFrom = $('#dateFrom').val();
            var dateTo = $('#dateTo').val();
            var roomType = $('#roomTypeDdl').val();
            var rateType = $('#rateTypeDdl').val();
            var roomId = $('#roomddl').val();
            var noOfHours = $('#hoursComboBox').val();

            if (!$('#divInvoice') || !$('#divInvoice')[0] || !$('#divInvoice')[0].innerText
                || $('#divInvoice')[0].innerText.trim().length <= 0) {
                return false;
            }

            // check checkin date 
            if (!dateFrom || dateFrom.length <= 0) {
                return false;
            }

            // check checkout date 
            if (!dateTo || dateTo.length <= 0) {
                return false;
            }

            if (!roomType || roomType === '-1') {
                return false;
            }

            if (!rateType || rateType === '-1') {
                return false;
            }

            if (!roomId || roomId === '-1') {
                return false;
            }

            if ($('#hourCheckin')[0].checked && noOfHours === '-1') {
                return false;
            }
            return true;
        },


        BindRoomDdl: function (ddlRoom, roomTypeId, rooms, shouldSkipBookedRoom) {
            var shouldNotifyRoomDashboardEvent = false;
            var hasSelectedRoomExists = false;
            if (!ddlRoom || !rooms || rooms.length <= 0) return;
            ddlRoom.empty();
            ddlRoom.append(new Option("Select Room", "-1"));
            var roomTypeId = parseInt(roomTypeId);
            if (roomTypeId > -1) {
                for (var i = 0; i < rooms.length; i++) {
                    if (rooms[i].RoomType.Id !== roomTypeId) continue;
                    if (shouldSkipBookedRoom && rooms[i].RoomStatus.Name.toLowerCase() === 'booked') continue;
                    if (parseInt(roomSelectedFromDashBoard) === parseInt(rooms[i].Id)) {
                        shouldNotifyRoomDashboardEvent = true;
                    }

                    if (roomIdFromDashboard > 0 && parseInt(roomIdFromDashboard) === parseInt(rooms[i].Id)) {
                        hasSelectedRoomExists = true;
                    }

                    ddlRoom.append(new Option(rooms[i].Number, rooms[i].Id));
                }
                // selected room id from dashboard available for booking when checkin or checkout date changes
                if (hasSelectedRoomExists) {
                    ddlRoom.val(roomIdFromDashboard);
                }
                else {
                    if (ddlRoom.find('option').length == 2)
                    {
                        ddlRoom.find('option')[1].selected = true;
                    }
                }
                // selected room id from dashboard doesnt available for booking when checkin or checkout date changes
                if (roomIdFromDashboard > 0 && !hasSelectedRoomExists) {
                    var optedRoomNumber = pmsSession.GetItem("optroomnumber");
                    alert("Room number " + optedRoomNumber + " is not available for this booking information");
                }

                if (window.Notifications) window.Notifications.Notify("on-resume-roomvalue", null, null);
                if (shouldNotifyRoomDashboardEvent && parseInt(roomSelectedFromDashBoard) > 0) {
                    if (window.Notifications) window.Notifications.Notify("on-sel-room-dashboard", null, null);
                }
            }
        },

        BindPropertyDdl: function (ddlProperty) {
            var properties = window.GuestCheckinManager.PropertySettingResponseDto.PropertySetting;
            if (!ddlProperty || !properties || properties.length <= 0) return;

            ddlProperty.empty();
            ddlProperty.append(new Option("Select Property", "-1"));
            for (var i = 0; i < properties.length; i++) {
                ddlProperty.append(new Option(properties[i].PropertyName, properties[i].Id));
            }
        },

        BindPaymentModeDdl: function (ddlPaymentType, paymentTypes) {
            if (!ddlPaymentType || !paymentTypes || paymentTypes.length <= 0) return;
            ddlPaymentType.empty();
            ddlPaymentType.append(new Option("Select Payment", "-1"));
            for (var i = 0; i < paymentTypes.length; i++) {
                ddlPaymentType.append(new Option(paymentTypes[i].Description, paymentTypes[i].Id));
            }
        },

        BindRoomTypeDdl: function (ddlRoomType, roomTypes) {
            if (!ddlRoomType || !roomTypes || roomTypes.length <= 0) return;
            ddlRoomType.empty();
            ddlRoomType.append(new Option("Select RoomType", "-1"));
            for (var i = 0; i < roomTypes.length; i++) {
                ddlRoomType.append(new Option(roomTypes[i].Name, roomTypes[i].Id));
            }
            //if (window.Notifications) window.Notifications.Notify("on-resume-roomtypevalue", null, null);
        },

        BindExtraChargesDdl: function (ddlExtraCharges, extraCharges) {
            if (!ddlExtraCharges || !extraCharges || extraCharges.length <= 0) return;
            ddlExtraCharges.empty();
            //ddlExtraCharges.append(new Option("Select Extracharges", "-1"));
            for (var i = 0; i < extraCharges.length; i++) {
                ddlExtraCharges.append(new Option(extraCharges[i].FacilityName, extraCharges[i].Id));
            }
        },

        BindPaymentTypeDdl: function (ddlPaymentType, paymentTypes) {
            if (!ddlPaymentType || !paymentTypes || paymentTypes.length <= 0) return;
            ddlPaymentType.empty();
            ddlPaymentType.append(new Option("Select PaymentType", "-1"));
            for (var i = 0; i < paymentTypes.length; i++) {
                ddlPaymentType.append(new Option(paymentTypes[i].Description, paymentTypes[i].Id));
            }
        },

        FillHourlyDdl: function (ddlHourly) {
            var rateTypeData = pmsSession.GetItem("roomratedata");
            var isHourlyCbChecked = $('#hourCheckin')[0].checked;
            if (!isHourlyCbChecked || !ddlHourly || !rateTypeData) return;
            var rateTypes = $.parseJSON(rateTypeData);
            if (!rateTypes || rateTypes.length <= 0) return;
            ddlHourly.empty();
            ddlHourly.append(new Option("Select Hrs", "-1"));
            for (var i = 0; i < rateTypes.length; i++) {
                if ((!rateTypes[i].Rates || rateTypes[i].Rates.length <= 0) ||
                    (isHourlyCbChecked && rateTypes[i].Units !== "Hourly")) continue;
                for (var j = 0; j < rateTypes[i].Rates.length; j++) {
                    var hrs = parseInt(rateTypes[i].Rates[j].InputKeyHours);
                    if (hrs <= 0) continue;
                    var isHourExists = false;
                    // check to avoid adding duplicate hours into hourly ddl
                    var ddlHourlyOptSelector = $("#hoursComboBox option");
                    for (var k = 0; k < ddlHourlyOptSelector.length; k++) {
                        if (!ddlHourlyOptSelector[k].text || isNaN(ddlHourlyOptSelector[k].text) ||
                            (parseInt(ddlHourlyOptSelector[k].text) !== hrs)) continue;
                        isHourExists = true;
                        break;
                    }
                    if (isHourExists) continue;

                    ddlHourly.append(new Option(hrs, rateTypes[i].Rates[j].Id));
                }
            }
            if ($("#hoursComboBox option") && $("#hoursComboBox option").length > 0) {
                sortHourlyDdl($("#hoursComboBox option"), ddlHourly);
            }
        },

        FilterRateType: function (ddlRateType, selectedHr) {
            var rateTypeData = pmsSession.GetItem("roomratedata");
            var isHourlyCbChecked = $('#hourCheckin')[0].checked;
            if (!ddlRateType || !rateTypeData) return;
            var rateTypes = $.parseJSON(rateTypeData);
            // if hourly cb is not checked then return 
            if (!rateTypes || rateTypes.length <= 0 || !isHourlyCbChecked) return;

            ddlRateType.empty();
            ddlRateType.append(new Option("Select RateType", "-1"));
            for (var i = 0; i < rateTypes.length; i++) {
                if ((!rateTypes[i].Rates || rateTypes[i].Rates.length <= 0) ||
                    !rateTypes[i].Hours || rateTypes[i].Hours <= 0 || rateTypes[i].Hours + "-hr" !== selectedHr) continue;
                ddlRateType.append(new Option(rateTypes[i].Name, rateTypes[i].Id));
            }
        },

        BindRateTypeDdl: function (ddlRateType) {
            var rateTypeData = pmsSession.GetItem("roomratedata");
            if (!ddlRateType || !rateTypeData) return;

            var rateTypes = $.parseJSON(rateTypeData);
            if (!rateTypes || rateTypes.length <= 0) return;
            var isHourlyCbChecked = $('#hourCheckin')[0].checked;

            ddlRateType.empty();
            ddlRateType.append(new Option("Select RateType", "-1"));
            for (var i = 0; i < rateTypes.length; i++) {
                if ((!rateTypes[i].Rates || rateTypes[i].Rates.length <= 0) ||
                    (!isHourlyCbChecked && rateTypes[i].Units !== "Daily") ||
                    (isHourlyCbChecked && rateTypes[i].Units !== "Hourly")) continue;
                ddlRateType.append(new Option(rateTypes[i].Name, rateTypes[i].Id));
            }

            if (ddlRateType.find('option').length == 2) {
                ddlRateType.find('option')[1].selected = true;
            }


        },

        BindStateDdl: function (countryId, ddlState, stateData) {
            stateData = !stateData ? pmsSession.GetItem("statedata") : stateData;
            if (!ddlState || !stateData) return;
            ddlState.empty();
            ddlState.append(new Option("Select State", "-1"));
            var stateSessionData = $.parseJSON(stateData);
            if (!stateSessionData || stateSessionData.length <= 0) return;
            var filterStates = filterStateByCountryId(countryId, stateSessionData);
            if (!filterStates || filterStates.length <= 0) return;
            for (var i = 0; i < filterStates.length; i++) {
                ddlState.append(new Option(filterStates[i].Name, filterStates[i].Id));
            }
        },

        BindCityDdl: function (stateId, ddlCity, cityData) {
            cityData = !cityData ? pmsSession.GetItem("citydata") : cityData;
            if (!ddlCity || !cityData) return;
            ddlCity.empty();
            ddlCity.append(new Option("Select City", "-1"));
            var citySessionData = $.parseJSON(cityData);
            if (!citySessionData || citySessionData.length <= 0) return;
            var filterCity = filterCityByStateId(stateId, citySessionData);
            if (!filterCity || filterCity.length <= 0) return;

            for (var i = 0; i < filterCity.length; i++) {
                ddlCity.append(new Option(filterCity[i].Name, filterCity[i].Id));
            }
        },

        GetCountry: function (ddlCountry) {
            ddlCountryObj = ddlCountry;
            var countryData = pmsSession.GetItem("countrydata");
            if (!countryData) {
                // get country by api calling  
                pmsService.GetCountry(args);
            } else {
                window.GuestCheckinManager.BindCountryDdl(ddlCountryObj);
                if (ddlCountryObj[0].id === 'ddlCountry') {
                    window.GuestCheckinManager.BindCountryDdl($('#ddlIdCountry'));
                }
            }
        },

        OnCountryChange: function (ddlCountry, ddlState, ddlCity) {
            if (!ddlCountry) return;
            if (ddlState) {
                ddlState.empty();
                ddlState.append(new Option("Select State", "-1"));
            }
            if (ddlCity) {
                ddlCity.empty();
                ddlCity.append(new Option("Select City", "-1"));
            }
            var countryId = ddlCountry.value;
            if (!countryId || countryId <= 0) return;

            var stateData = pmsSession.GetItem("statedata");
            if (stateData) {
                window.GuestCheckinManager.BindStateDdl(countryId, ddlState, stateData);
            }
        },

        OnStateChange: function (ddlState, ddlCity) {
            if (!ddlState) return;
            if (ddlCity) {
                ddlCity.empty();
                ddlCity.append(new Option("Select City", "-1"));
            }
            var stateId = ddlState.value;
            if (!stateId || stateId <= 0) return;

            var cityData = pmsSession.GetItem("citydata");
            if (cityData) {
                window.GuestCheckinManager.BindCityDdl(stateId, ddlCity, cityData);
            }
        },

        BindCountryDdl: function (ddlCountry) {
            var countryData = pmsSession.GetItem("countrydata");
            if (!ddlCountry || !countryData) return;
            var country = $.parseJSON(countryData);
            if (!country || country.length <= 0) return;
            ddlCountry.empty();
            ddlCountry.append(new Option("Select Country", "-1"));
            for (var i = 0; i < country.length; i++) {
                ddlCountry.append(new Option(country[i].Name, country[i].Id));
            }
        },

        AddInvoice: function () {

            var invoiceRequestDto = {};
            invoiceRequestDto.Invoice = {};
            var invoice = {};

            invoice.InvoiceTaxDetails = [];
            invoice.InvoiceItems = [];
            invoice.InvoicePaymentDetails = [];

            invoice.PropertyId = getPropertyId();
            invoice.BookingId = window.GuestCheckinManager.BookingDto.BookingId ? window.GuestCheckinManager.BookingDto.BookingId : -1;
            //invoice.BookingId = 2116;
            if (invoice.PropertyId <= -1 || invoice.BookingId <= -1) {
                $('#saveInvoice').attr("disabled", true);
                alert('Invalid bookingid or propertyid.');
                return;
            }

            invoice.Id = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;
            //invoice.Id = 1038;
            invoice.GuestId = window.GuestCheckinManager.BookingDto.GuestId ? window.GuestCheckinManager.BookingDto.GuestId : -1;
            //invoice.GuestId = 2082;
            invoice.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            invoice.IsActive = true;
            invoice.TotalAmount = $('#total') ? $('#total').val() : 0;
            invoice.DiscountPercent = $('#discountPercent') && $('#discountPercent')[0] ? $('#discountPercent')[0].value.replace('%', '') : 0;
            invoice.DiscountAmount = $('#discountAmt') && $('#discountAmt')[0] ? $('#discountAmt')[0].value : 0;
            invoice.IsPaid = $('#balance') && $('#balance').val() > 0 ? false : true;
            invoice.CreatedBy = getCreatedBy();

            // predefined tax 
            invoice.InvoiceTaxDetails = prepareTax();
            // dynamic tax and other payment charges
            invoice.InvoiceItems = prepareOtherCharges();
            invoice.InvoicePaymentDetails = preparePaymentDetail();

            var creditName = $('#creditName').val();
            var creditNumber = $('#creditNumber').val();
            var creditExpiry = $('#creditExpiry').val();
            var cardType = $('#cardType').val();
            if (creditNumber && creditNumber.trim() !== "" && creditNumber.length > 0) {
                invoice.CreditCardDetail = creditNumber + "|" + creditName + "|" + creditExpiry + "|" + cardType;
            } else {
                invoice.CreditCardDetail = "";
            }

            invoiceRequestDto.Invoice = invoice;
            // add invoice by api calling  
            pmsService.AddInvoice(invoiceRequestDto);
        },

        AddBooking: function (status, shouldRefund) {
            bookingStatus = status;
            // default value as false
            shouldRefund = !shouldRefund ? false : shouldRefund;
            var bookingRequestDto = {};
            bookingRequestDto.Booking = {};
            var booking = {};
            // for new booking Id = -1 
            booking.Id = window.GuestCheckinManager.BookingDto.BookingId ? window.GuestCheckinManager.BookingDto.BookingId : -1;
            booking.CheckinTime = $('#dateFrom').val();
            booking.CheckoutTime = $('#dateTo').val();
            booking.NoOfAdult = $('#ddlAdults').val();
            booking.NoOfChild = $('#ddlChild').val();
            booking.PropertyId = getPropertyId();
            booking.GuestRemarks = $('#guestComments').val();
            booking.TransactionRemarks = $('#transRemarks').val();
            booking.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            booking.Status = status;
            booking.ShouldRefund = shouldRefund;
            booking.IsActive = true;
            booking.ISHOURLYCHECKIN = $('#hourCheckin')[0].checked ? true : false;
            booking.RateTypeId = $('#rateTypeDdl').val();
            var noOfHours = window.GuestCheckinManager.GetSelectedCheckoutHrs();
            booking.HOURSTOSTAY = $('#hourCheckin')[0].checked && parseInt(noOfHours) > 0 ? parseInt(noOfHours) : 0;
            booking.CreatedBy = getCreatedBy();
            booking.RoomBookings = prepareRoomBooking();
            booking.Guests = prepareGuest();
            booking.GuestMappings = prepareGuestMapping();
            booking.Addresses = prepareAddress();
            booking.AdditionalGuests = prepareAdditionalGuest();
            booking.LastUpdatedBy = getCreatedBy();
            booking.LastUpdatedOn = window.GuestCheckinManager.GetCurrentDate();

            if (!booking.RoomBookings || !booking.Guests || !booking.Addresses) {
                console.error('Room Booking can not be done.');
                alert("Room Booking can not be done.");
                return;
            }
            bookingRequestDto.Booking = booking;
            // add booking by api calling  
            pmsService.AddBooking(bookingRequestDto);
        },

        GetRoomByDate: function (dtFrom, dtTo, roomId) {
            var getRoomByDateRequestDto = {};
            roomIdFromDashboard = roomId && roomId > 0 ? roomId : -1;            
            getRoomByDateRequestDto.CheckinDate = dtFrom;
            getRoomByDateRequestDto.CheckoutDate = dtTo;
            getRoomByDateRequestDto.PropertyId = getPropertyId();
            // get room by api calling  
            pmsService.GetRoomByDate(getRoomByDateRequestDto);
        },


        GetGuestHistory: function () {
            args.guestId = window.GuestCheckinManager.BookingDto.GuestId ? window.GuestCheckinManager.BookingDto.GuestId : -1;
            if (args.guestId != -1) {

                var guestData = pmsSession.GetItem("guesthistory");
                if (!guestData) {
                    pmsService.GetGuestHistoryById(args);
                    return;
                }
                var guestSessionData = $.parseJSON(guestData);
                if (!guestSessionData || guestSessionData.length <= 0) return;
                var idx = window.GuestCheckinManager.CheckIfKeyPresent(args.guestId, guestSessionData);
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

        GetStateByCountry: function (countryId) {
            var stateData = pmsSession.GetItem("statedata");
            if (!stateData) {
                args.Id = countryId;
                // get state by api calling  
                pmsService.GetStateByCountry(args);
            }
        },

        GetCityByState: function (stateId) {
            var cityData = pmsSession.GetItem("citydata");
            if (!cityData) {
                args.Id = stateId;
                // get city by api calling  
                pmsService.GetCityByState(args);
            }
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
            if (searchText.indexOf(',') >= 0) {
                searchText = searchText.split(',')[0];
            }

            for (var i = 0; i < data.length; i++) {
                // lookup for fname,lname,guestid,email,mobile#
                if (!data[i] || (data[i].FirstName.toLowerCase().indexOf(searchText) < 0 &&
                        data[i].LastName.toLowerCase().indexOf(searchText) < 0 &&
                        data[i].EmailAddress.toLowerCase().indexOf(searchText) < 0 &&
                        data[i].MobileNumber.toString().indexOf(searchText) < 0)) {

                    if (!data[i] || !data[i].GuestMappings || data[i].GuestMappings.length <= 0) continue;
                    // look up for guest id number
                    for (var j = 0; j < data[i].GuestMappings.length; j++) {
                        if (!data[i].GuestMappings[j].IDDETAILS ||
                            data[i].GuestMappings[j].IDDETAILS.toLowerCase().indexOf(searchText) < 0) continue;

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
                window.GuestCheckinManager.BookingDto.GuestId = null;
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
            if (divInvoice && divInvoice.length > 0) {
                divInvoice[0].style.cssText = "display: block;"
            }

            // if it is not getinvoice api call
            if (!data.Invoice || !data.Invoice.Id || data.Invoice.Id <= 0) {
                //data = appendTotalRoomCharge(data);
                divInvoice.html(invoiceTemplate.render(data));
            } else {
                divInvoice.html(invoiceTemplate.render(data.Invoice));
            }
            var paymentTypes = pmsSession.GetItem("paymenttype");
            var extraCharges = pmsSession.GetItem("extracharges");
            var data = $.parseJSON(paymentTypes);
            var extraChargesdata = $.parseJSON(extraCharges);
            // data not present in session
            if (!paymentTypes || !data || data.length <= 0) {
                Notifications.SubscribeActive("on-paymenttype-get-success", function (sender, args) {
                    var paymentData = window.GuestCheckinManager.PropertySettingResponseDto.PaymentTypeSettings;
                    window.GuestCheckinManager.BindPaymentTypeDdl($('#paymentTypeDdl'), paymentData);
                    window.GuestCheckinManager.BindPaymentTypeDdl($('#paymentTypeDdlOther'), paymentData);
                });
                window.GuestCheckinManager.GetPaymentType();
            } else {
                window.GuestCheckinManager.BindPaymentTypeDdl($('#paymentTypeDdl'), data);
                window.GuestCheckinManager.BindPaymentTypeDdl($('#paymentTypeDdlOther'), data);
            }

            // data not present in session
            //if (!extraCharges || !extraChargesdata || extraChargesdata.length <= 0) {
            //    Notifications.SubscribeActive("on-extracharge-get-success", function(sender, args) {
            //        var extraChargedata = window.GuestCheckinManager.PropertySettingResponseDto.ExtraChargeSettings;
            //        window.GuestCheckinManager.BindExtraChargesDdl($('#ddlExtraCharges'), extraChargedata);
            //        window.GuestCheckinManager.BindExtraChargesDdl($('#ddlExtraChargesClone'), extraChargedata);
            //    });
            //    window.GuestCheckinManager.GetExtraCharge();
            //} else {
            //    window.GuestCheckinManager.BindExtraChargesDdl($('#ddlExtraCharges'), extraChargesdata);
            //    window.GuestCheckinManager.BindExtraChargesDdl($('#ddlExtraChargesClone'), extraChargesdata);
            //}
            window.GuestCheckinManager.CalculateInvoice();
            if (isCheckoutDateModified) {
                if (window.Notifications) window.Notifications.Notify("on-checkout-date-change", null, null);
            }
        },

        IsTime: function (e) {
            var key = e.keyCode;
            if (key === 9 || e.shiftKey && key === 186) return true;
            if (e.shiftKey || e.ctrlKey || e.altKey) {
                e.preventDefault();
                return false;
            } else {
                if (!((key == 8) || (key == 46) || (key >= 35 && key <= 40) || (key >= 48 && key <= 57) || (key >= 96 && key <= 105))) {
                    e.preventDefault();
                    return false;
                }
            }
            return true;
        },

        IsNumeric: function (e) {
            var key = e.keyCode;
            if (key === 9) return true;
            if (e.shiftKey || e.ctrlKey || e.altKey) {
                e.preventDefault();
                return false;
            } else {
                if (!((key == 8) || (key == 46) || (key >= 35 && key <= 40) || (key >= 48 && key <= 57) || (key >= 96 && key <= 105))) {
                    e.preventDefault();
                    return false;
                }
            }
            return true;
        },

        CalculateInvoice: function (isElementDiscountAmt, isfromBackCalculate) {
            var totalCharge = 0;
            var totalTax = 0;
            var paymentAmt = 0;
            var stayDays = 1;
            var dateFrom = $('#dateFrom').val();
            var dateTo = $('#dateTo').val();
            if (!dateFrom || !dateTo) {
                stayDays = 1;
            } else {
                var daysDiff = window.GuestCheckinManager.GetDays(dateFrom, dateTo);
                stayDays = daysDiff <= 0 ? 1 : daysDiff;
            }
            var baseRoomCharge = $('#baseRoomCharge');
            var totalRoomCharge = $('#totalRoomCharge');
            var taxElementCol = $("input[id*='taxVal']");
            var otherTaxElementCol = $("input[id*='otherTaxVal']");
            var paymentValueCol = $("td[id*='tdPaymentValue']");
            var paymentValueColNew = $("td[id*='tdPaymentValue'] input");
            var invoiceObject = window.GuestCheckinManager.invoiceData.Invoice;
            var totRoomCharge = 0;
            //  room base charge calculations
            var baseCharge = baseRoomCharge && baseRoomCharge.val() && !isNaN(baseRoomCharge.val()) ? parseFloat(baseRoomCharge.val(), 10).toFixed(2) : 0;
            if (totalRoomCharge && baseCharge > 0) {
                //  total room charge calculations
                totalRoomCharge.val(parseFloat(baseCharge).toFixed(2) * stayDays);
                totRoomCharge = parseFloat(totalRoomCharge.val(), 10);
            }

            //  tax charges calculations
            if (taxElementCol && taxElementCol.length > 0) {
                for (var i = 0; i < taxElementCol.length; i++) {
                    var taxName = taxElementCol[i].name;
                    if (!taxElementCol[i] || !taxElementCol[i].value || !taxName) continue;
                    var taxPercent = taxElementCol[i].value.replace('%', '');
                    if (isNaN(taxPercent)) continue;
                    var taxNameSelector = $('input[id="' + taxName+'"]');
                    var taxCalulatedSelector = $('input[id="taxCalulatedVal' + taxName + '"]');
                    if (!taxNameSelector[0].checked) {
                        taxCalulatedSelector[0].value = 0;
                        continue;
                    }
                    taxCalulatedSelector[0].value = ((parseFloat(taxPercent, 10) * totRoomCharge) / 100).toFixed(2);
                    totalTax = (parseFloat(totalTax) + parseFloat(taxPercent, 10)).toFixed(2);
                }
            }

            totalCharge = (totRoomCharge + (parseFloat(totalTax) * totRoomCharge) / 100).toFixed(2);
            totalCharge = applyDiscount(totalCharge, isElementDiscountAmt);

            //other tax charges calculations
            if (otherTaxElementCol && otherTaxElementCol.length > 0) {
                for (var i = 0; i < otherTaxElementCol.length; i++) {
                    if (!otherTaxElementCol[i] || !otherTaxElementCol[i].value || isNaN(otherTaxElementCol[i].value)) continue;
                    totalCharge = (parseFloat(totalCharge) + parseFloat(otherTaxElementCol[i].value, 10)).toFixed(2);
                }
            }
            if (!isfromBackCalculate)
                $('#total').val(totalCharge);

            var idx = 0;
            //  payment calulations
            if (paymentValueCol && paymentValueCol.length > 0) {
                for (var i = 0; i < paymentValueCol.length; i++) {
                    if (!paymentValueCol[i]) continue;
                    var value = paymentValueCol[i].innerText;
                    if (value.trim() === "") {
                        value = paymentValueColNew[idx].value;
                        idx++;
                        if (value.trim() === "") {
                            value = 0;
                        }
                    }
                    paymentAmt = (parseFloat(paymentAmt) + parseFloat(value)).toFixed(2);
                }
            }

            var balanceAmt = $('#total').val() - paymentAmt;
            $('#payment').val(paymentAmt);
            $('#balance').val(balanceAmt);
            $('#credit').val(balanceAmt);

            $('.pms-money').moneyFormat();

            return $('#total').val();
        },

        BackCalculateInvoice: function () {
            var totalCharge = $('#total').val();
            var totalTax = 0;
            var paymentAmt = 0;
            var stayDays = 1;
            var dateFrom = $('#dateFrom').val();
            var dateTo = $('#dateTo').val();
            if (!dateFrom || !dateTo) {
                stayDays = 1;
            } else {
                var daysDiff = window.GuestCheckinManager.GetDays(dateFrom, dateTo);
                stayDays = daysDiff <= 0 ? 1 : daysDiff;
            }
            var baseRoomCharge = $('#baseRoomCharge');
            var totalRoomCharge = $('#totalRoomCharge');
            var taxElementCol = $("input[id*='taxVal']");
            var otherTaxElementCol = $("input[id*='otherTaxVal']");
            var paymentValueCol = $("td[id*='tdPaymentValue']");
            var paymentValueColNew = $("td[id*='tdPaymentValue'] input");
            var invoiceObject = window.GuestCheckinManager.invoiceData.Invoice;
            var totRoomCharge = 0;


            //  tax charges calculations
            if (taxElementCol && taxElementCol.length > 0) {
                for (var i = 0; i < taxElementCol.length; i++) {
                    var taxName = taxElementCol[i].name;
                    if (!taxElementCol[i] || !taxElementCol[i].value || !taxName) continue;
                    var taxPercent = taxElementCol[i].value.replace('%', '');
                    if (isNaN(taxPercent)) continue;
                    totalTax = (parseFloat(totalTax) + parseFloat(taxPercent, 10)).toFixed(2);
                }
            }

            //other tax charges calculations
            if (otherTaxElementCol && otherTaxElementCol.length > 0) {
                for (var i = 0; i < otherTaxElementCol.length; i++) {
                    if (!otherTaxElementCol[i] || !otherTaxElementCol[i].value || isNaN(otherTaxElementCol[i].value)) continue;
                    totalCharge = (parseFloat(totalCharge) - parseFloat(otherTaxElementCol[i].value, 10)).toFixed(2);
                }
            }

            //Discount
            var discountPercent = $('#discountPercent').val().replace('%', '');
            discountPercent = !discountPercent || isNaN(discountPercent) ? 0 : parseFloat(discountPercent, 10).toFixed(2);
            if (discountPercent > 0) {
                totalRoomCharge.val(parseFloat(10000 * parseFloat(totalCharge) / (10000 + 100 * parseFloat(totalTax) - 100 * parseFloat(discountPercent) - parseFloat(discountPercent) * parseFloat(totalTax)), 10).toFixed(2));
            }
            else {
                var discountedAmount = $('#discountAmt').val().trim() === '' || isNaN($('#discountAmt').val()) || parseFloat($('#discountAmt').val()) <= 0 ? 0 : parseFloat($('#discountAmt').val());
                totalCharge = (parseFloat(totalCharge) + parseFloat(discountedAmount)).toFixed(2);
                totalRoomCharge.val(parseFloat(100 * totalCharge / (100 + parseFloat(totalTax))).toFixed(2));
            }
            baseRoomCharge.val((parseFloat(totalRoomCharge.val(), 10) / stayDays).toFixed(2));

            gcm.CalculateInvoice(null, true);
        },

        GetInvoiceById: function (invoiceId) {
            // GetInvoiceById details by api calling 
            var getInvoiceRequestDto = {};
            getInvoiceRequestDto = prepareLoadInvoiceRequestDto();
            getInvoiceRequestDto.InvoiceId = invoiceId;

            pmsService.GetInvoiceById(getInvoiceRequestDto);
        },

        GetPaymentCharges: function () {
            // get paymentCharge details by api calling 
            var getInvoiceRequestDto = {};
            getInvoiceRequestDto = prepareLoadInvoiceRequestDto();

            pmsService.GetPaymentCharges(getInvoiceRequestDto);
        },

        GetBookingById: function (bookingId) {
            if (bookingId <= 0) return;
            args.bookingId = bookingId;
            window.GuestCheckinManager.BookingDto.BookingId = bookingId;
            pmsService.GetBookingById(args);
        },

        LoadInvoice: function (checkoutDateModified) {
            if (!validateLoadInvoiceCall()) return;
            window.GuestCheckinManager.ToggleInvoiceWarning($('#invoiceWarning'), false);
            $('.img-no-available').hide();
            var invoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;
            //invoiceId = 1038;
            $('#rateTypeDdl').attr("disabled", false);

            if (invoiceId === -1) {
                window.GuestCheckinManager.GetPaymentType();
                window.GuestCheckinManager.GetPaymentCharges();
            }
            else {
                isCheckoutDateModified = !checkoutDateModified ? false : true;
                window.GuestCheckinManager.GetInvoiceById(invoiceId);
            }

        },

        PopulateUi: function (data) {
            var guest = data[0].Guests[0];
            var invoice = data[0].Invoice;
            var roombooking = data[0].RoomBookings[0];
            var address = data[0].Addresses[0];
            var additionalguest = data[0].AdditionalGuests[0];
            var guestmapping = data[0].GuestMappings[0];

            window.GuestCheckinManager.BookingDto.GuestId = guest && guest.Id && guest.Id > 0 ? guest.Id : -1;
            window.GuestCheckinManager.BookingDto.InvoiceId = invoice && invoice.Id && invoice.Id > 0 ? invoice.Id : -1;
            window.GuestCheckinManager.BookingDto.RoomBookingId = roombooking && roombooking.Id && roombooking.Id > 0 ? roombooking.Id : -1;
            window.GuestCheckinManager.BookingDto.AddressId = address && address.Id && address.Id > 0 ? address.Id : -1;
            window.GuestCheckinManager.BookingDto.AdditionalGuestId = additionalguest && additionalguest.Id && additionalguest.Id > 0 ? additionalguest.Id : -1;
            window.GuestCheckinManager.BookingDto.GuestMappingId = guestmapping && guestmapping.Id && guestmapping.Id > 0 ? guestmapping.Id : -1;
            window.GuestCheckinManager.BookingDto.PropertyId = getPropertyId();

            populateRoomDetails(data);

            if (guest) {
                window.GuestCheckinManager.PopulateGuestDetails(guest);
            }

            if (guestmapping) {
                populateGuestMapping(guestmapping);
            }

            if (additionalguest) {
                populateAdditionalGuest(additionalguest);
            }

            if (address) {
                populateAddress(address);
            }
            // As of now business reqs doesnt want to make UI fields readonly
            //if (data[0].Status === 'checkout') {
            //    window.GuestCheckinManager.MakeReadOnly(true);
            //}

            if (data[0].Status === 'reserved') {
                $("#btnCancelReserved").show();
            }
            else if (data[0].Status === 'checkout') {
                //Date can't be changed
                $('#dateFrom').prop("disabled", true);
                $('#dateTo').prop("disabled", true);
                $('#btnCheckout').prop("disabled", true);
                $('#btnCheckin').prop("disabled", true);
            }
        },

        ClearPropertyFields: function () {
            $('#propertyName').val('');
            $('#closeofdaytime').val('');
            $('#checkintime').val('');
            $('#checkouttime').val('');
            $('#owner').val('');
            $('#propertyCode').val('');
            $('#fulladdress').val('');
            $('#website').val('');
            $('#phone').val('');
            $('#fax').val('');
            $('#email').val('');
            //$('#dateTo').val();
            $('#timezone').val('');
            $('#currency').val('');
            $('#ddlState').val('-1');
            $('#ddlCountry').val('-1');
            $('#ddlCity').val('-1');
            $('#zipCode').val('');
            $('#secondaryName').val('');
            $('#uploadPhoto').val('');
            $('#imgPhoto').attr('src', '');
            $('#imgPhoto').css('visibility', 'hidden');
            $('#imgPhoto').removeClass('photo-added');
            if ($('#lblLogo') && $('#lblLogo').length > 0 && $('#lblLogo')[0]) {
                $('#lblLogo')[0].style = '';
            }
        },

        ClearUserFields: function () {
            $('#userName').val('');
            $('#password').val('');
            $('#confirmPassword').val('');
            $('#firstName').val('');
            $('#lastName').val('');
            $('#mobileNumber').val('');
            $('#emailAddress').val('');
            $('#dob').val('');
            $('#ddlGender').val('');
        },

        ClearAllFields: function () {
            window.GuestCheckinManager.Initialize();
            window.GuestCheckinManager.MakeReadOnly(false);
            $("#fName").val('');
            $("#lName").val('');
            $("#dateFrom").val('');
            $("#dateTo").val('');
            $('#roomTypeDdl').val('-1');
            $('#ddlIdType').val('-1');
            $('#roomddl').empty();
            $("#searchGuest").val('');
            $('#idDetails').val('');
            $('#zipCode').val('');
            $('#phone').val('');
            $('#email').val('');
            $('#address').val('');
            $('#transRemarks').val('');
            $('#guestComments').val('');
            $("#ddlAdults").val('1');
            $("#ddlChild").val('0');
            $("#dob").val('');
            $("#idExpiry").val('');
            $("#adFName").val('');
            $("#adLName").val('');
            $('#ddlIdType').val('-1');
            $('#ddlIdCountry').val('-1');
            $('#ddlCountry').val('-1');
            $('#ddlState').empty();
            $('#ddlIdState').empty();
            $('#ddlCity').empty();
            $('#saveInvoice').attr("disabled", true);
            $('#btnSave').attr("disabled", true);
            $('#btnCheckout').attr("disabled", true);
            $('#btnCheckin').attr("disabled", false);
            $('.img-no-available').show();
            $('#divInvoice').html('');
            $('#divInvoice').hide();
            $('#ddlState').append(new Option("Select State", "-1"));
            $('#ddlIdState').append(new Option("Select State", "-1"));
            $('#ddlCity').append(new Option("Select City", "-1"));
            $('#roomddl').append(new Option("Select Room", "-1"));
            $('#imgPhoto').attr('src', '');
            $('#imgAdditionalPhoto').attr('src', '');
            $('#imgPhoto').css('visibility', 'hidden');
            $('#imgPhoto').removeClass('photo-added');
            $('#imgAdditionalPhoto').css('visibility', 'hidden');
            $('#imgAdditionalPhoto').removeClass('photo-added');
            $('#hourCheckin')[0].checked = false;
            $('#hoursComboBox').val(-1);
            $('#hoursComboBox').prop("disabled", true);
            $('#rateTypeDdl').empty();
            window.GuestCheckinManager.BindRateTypeDdl($('#rateTypeDdl'));
            $('#rateTypeDdl').val('-1');
            window.GuestCheckinManager.BookingDto.GuestId = null;
            window.GuestCheckinManager.BookingDto.InvoiceId = null;
            window.GuestCheckinManager.BookingDto.RoomBookingId = null;
            window.GuestCheckinManager.BookingDto.AddressId = null;
            window.GuestCheckinManager.BookingDto.AdditionalGuestId = null;
            window.GuestCheckinManager.BookingDto.GuestMappingId = null;
            window.GuestCheckinManager.BookingDto.BookingId = null;
            window.GuestCheckinManager.AutoCollapseGuestHistory();
        },

        MakeReadOnly: function (shouldMakeReadOnly) {
            $("#dateFrom").prop("disabled", shouldMakeReadOnly);
            $("#dateTo").prop("disabled", shouldMakeReadOnly);
            $('#roomTypeDdl').attr("disabled", shouldMakeReadOnly);
            $('#rateTypeDdl').attr("disabled", shouldMakeReadOnly);
            $('#roomddl').attr("disabled", shouldMakeReadOnly);
            $('#ddlAdults').attr("disabled", shouldMakeReadOnly);
            $('#ddlChild').attr("disabled", shouldMakeReadOnly);
            $("#searchGuest").prop("readonly", shouldMakeReadOnly);
            $('#zipCode').prop("readonly", shouldMakeReadOnly);
            $('#phone').prop("readonly", shouldMakeReadOnly);
            $('#email').prop("readonly", shouldMakeReadOnly);
            $('#address').prop("readonly", shouldMakeReadOnly);
            $('#transRemarks').prop("readonly", shouldMakeReadOnly);
            $('#guestComments').prop("readonly", shouldMakeReadOnly);
            $("#dob").prop("disabled", shouldMakeReadOnly);
            $("#idExpiry").prop("disabled", shouldMakeReadOnly);
            $("#adFName").prop("readonly", shouldMakeReadOnly);
            $("#adLName").prop("readonly", shouldMakeReadOnly);
            $('#ddlIdCountry').attr("disabled", shouldMakeReadOnly);
            $('#ddlCountry').attr("disabled", shouldMakeReadOnly);
            $('#ddlState').attr("disabled", shouldMakeReadOnly);
            $('#ddlIdState').attr("disabled", shouldMakeReadOnly);
            $('#ddlCity').attr("disabled", shouldMakeReadOnly);
            $('#hoursComboBox').prop("disabled", shouldMakeReadOnly);
            $('#hourCheckin').prop("disabled", shouldMakeReadOnly);
            $('#uploadPhoto').attr("disabled", shouldMakeReadOnly);
            $('#additionalUpload').attr("disabled", shouldMakeReadOnly);
            window.GuestCheckinManager.MakeGuestInfoReadOnly(shouldMakeReadOnly);
        },

        MakeGuestInfoReadOnly: function (shouldMakeReadOnly) {
            $("#fName").prop("readonly", shouldMakeReadOnly);
            $("#lName").prop("readonly", shouldMakeReadOnly);
            $('#ddlInitials').attr("disabled", shouldMakeReadOnly);
            $("#idDetails").prop("readonly", shouldMakeReadOnly);
            $('#ddlIdType').attr("disabled", shouldMakeReadOnly);
        },

        GetAllProperty: function () {

            var userId = window.PmsSession.GetItem("userid");
            args.userId = userId > 0 ? userId : 0;
            // get property by api calling 
            pmsService.GetAllProperty(args);
        },
        GetPropertyForAccess: function () {
            if (window.GuestCheckinManager.PropertySettingResponseDto.PropertyForAccessSetting && window.GuestCheckinManager.PropertySettingResponseDto.PropertyForAccessSetting.length > 0) {
                var panelProperty = $('#panelProperty');
                if (panelProperty) {
                    window.GuestCheckinManager.BindPropertyPanel($('#panelProperty .left ul'), window.GuestCheckinManager.PropertySettingResponseDto.PropertyForAccessSetting);
                }
            }
            else
                pmsService.GetPropertyForAccess(args);
        },

        PopulateBookingGrid: function (data) {
            var divBooking = $('#divBooking');
            var bookingTemplate = $('#bookingTemplate');
            var rangeProperty = $('#rangeProperty');
            var rangeTemplate = $('#rangeTemplate');

            if (!divBooking || !bookingTemplate || !rangeProperty || !rangeTemplate) return;

            divBooking.html('');
            divBooking.html(bookingTemplate.render(data));
            if (!(window.location.pathname.toLowerCase().indexOf('reports/viewtransaction') >= 0)) {
                $("#divBooking thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
                if (data && data.Bookings && data.Bookings.length > 0) {
                    $("#divBooking tbody tr").append('<td class="finalActionsCol"><i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');
                }
            }
            rangeProperty.html('');
            rangeProperty.html(rangeTemplate.render(data));

            $('.decimal').moneyFormat();
        },

        PopulatePropertyGrid: function (data) {
            var divProperty = $('#divProperty');
            var propertyTemplate = $('#propertyTemplate');
            if (!divProperty || !propertyTemplate) return;
            divProperty.html(propertyTemplate.render(data));
            $("#divProperty thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
            $("#divProperty tbody tr").append('<td class="finalActionsCol"><i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');
        },

        PopulateRateTab: function (data) {
            var divRoomRate = $('#divRoomRate');
            var roomRateTemplate = $('#roomRateTemplate');
            if (!divRoomRate || !roomRateTemplate || divRoomRate.length <= 0 || roomRateTemplate.length <= 0) return;
            divRoomRate.html('');
            if (!data || !data.RoomRate || data.RoomRate.length <= 0) return;
            divRoomRate.html(roomRateTemplate.render(data));
        },

        PopulateRoomRateInGrid: function (data) {
            var rateData = window.GuestCheckinManager.PropertySettingResponseDto.RateSettings;
            var divManageRate = $('#divManageRate');
            var manageRateTemplate = $('#manageRateTemplate');
            if (!divManageRate || !manageRateTemplate || divManageRate.length <= 0 || manageRateTemplate.length <= 0) return;
            divManageRate.html('');
            if (!rateData || rateData.length <= 0) return;
            divManageRate.html(manageRateTemplate.render(data));
            $("#divManageRate thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
            if (data && data.Rates && data.Rates.length > 0) {
                $("#divManageRate tbody tr").append('<td class="finalActionsCol"><i class="fa fa-plus-circle" aria-hidden="true"></i> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');
            } else {
                // when no room rate data is present in db 
                $("#divManageRate tbody tr").append('<td class="finalActionsCol"><i class="fa fa-floppy-o editMode" aria-hidden="true"></i></td>');
                window.GuestCheckinManager.FillRoomTypeData($('#ddlRoomTypeAdd'), $('#ddlProperty').val());
            }
            $('.decimal').moneyFormat();
        },

        PopulateTaxGrid: function (data) {
            var divTax = $('#divTax');
            var taxTemplate = $('#taxTemplate');
            if (!divTax || !taxTemplate || divTax.length <= 0 || taxTemplate.length <= 0) return;
            divTax.html(taxTemplate.render(data));
            $("#divTax thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
            if (data && data.Taxes && data.Taxes.length > 0) {
                $("#divTax tbody tr").append('<td class="finalActionsCol"><i class="fa fa-plus-circle" aria-hidden="true"></i> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');
            } else {
                // when no tax data is present in db 
                $("#divTax tbody tr").append('<td class="finalActionsCol"><i class="fa fa-floppy-o editMode" aria-hidden="true"></i></td>');
            }
        },

        PopulateExtraChargeGrid: function (data) {
            var divExtraCharge = $('#divExtraCharge');
            var extrachargeTemplate = $('#extrachargeTemplate');
            if (!divExtraCharge || !extrachargeTemplate || divExtraCharge.length <= 0 || extrachargeTemplate.length <= 0) return;
            divExtraCharge.html(extrachargeTemplate.render(data));
            $("#divExtraCharge thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
            if (data && data.ExtraCharges && data.ExtraCharges.length > 0) {
                $("#divExtraCharge tbody tr").append('<td class="finalActionsCol"><i class="fa fa-plus-circle" aria-hidden="true"></i> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');
            } else {
                // when no extraCharge data is present in db 
                $("#divExtraCharge tbody tr").append('<td class="finalActionsCol"><i class="fa fa-floppy-o editMode" aria-hidden="true"></i></td>');
            }
            $('.decimal').moneyFormat();
        },

        PopulatePaymentTypeGrid: function (data) {
            var divPaymentType = $('#divPaymentType');
            var paymenttypeTemplate = $('#paymenttypeTemplate');
            if (!divPaymentType || !paymenttypeTemplate || divPaymentType.length <= 0 || paymenttypeTemplate.length <= 0) return;
            divPaymentType.html(paymenttypeTemplate.render(data));
            $("#divPaymentType thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
            if (data && data.PaymentTypes && data.PaymentTypes.length > 0) {
                $("#divPaymentType tbody tr").append('<td class="finalActionsCol"><i class="fa fa-plus-circle" aria-hidden="true"></i> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');
            } else {
                // when no paymenttype data is present in db 
                $("#divPaymentType tbody tr").append('<td class="finalActionsCol"><i class="fa fa-floppy-o editMode" aria-hidden="true"></i></td>');
            }
        },

        PopulateFloorGrid: function (data) {
            var divFloor = $('#divFloor');
            var floorTemplate = $('#floorTemplate');
            if (!divFloor || !floorTemplate || divFloor.length <= 0 || floorTemplate.length <= 0) return;
            divFloor.html(floorTemplate.render(data));
            $("#divFloor thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
            if (data && data.PropertyFloors && data.PropertyFloors.length > 0) {
                $("#divFloor tbody tr").append('<td class="finalActionsCol"><i class="fa fa-plus-circle" aria-hidden="true"></i> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');
            } else {
                // when no floor data is present in db 
                $("#divFloor tbody tr").append('<td class="finalActionsCol"><i class="fa fa-floppy-o editMode" aria-hidden="true"></i> </td>');
            }
        },

        PopulateRateTypeGrid: function (data) {
            var divRateType = $('#divRateType');
            var rateTemplate = $('#rateTemplate');
            if (!divRateType || !rateTemplate || divRateType.length <= 0 || rateTemplate.length <= 0) return;
            divRateType.html(rateTemplate.render(data));
            $("#divRateType thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
            if (data && data.RateTypes && data.RateTypes.length > 0) {
                $("#divRateType tbody tr").append('<td class="finalActionsCol"><i class="fa fa-plus-circle" aria-hidden="true"></i> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');
            } else {
                // when no ratetype data is present in db 
                $("#divRateType tbody tr").append('<td class="finalActionsCol"><i class="fa fa-floppy-o editMode" aria-hidden="true"></i></td>');
            }
        },

        PopulateRoomTypeGrid: function (data) {
            var divRoomType = $('#divRoomType');
            var roomtypeTemplate = $('#roomtypeTemplate');
            if (!divRoomType || !roomtypeTemplate || divRoomType.length <= 0 || roomtypeTemplate.length <= 0) return;
            divRoomType.html(roomtypeTemplate.render(data));
            $("#divRoomType thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
            if (data && data.RoomTypes && data.RoomTypes.length > 0) {
                $("#divRoomType tbody tr").append('<td class="finalActionsCol"><i class="fa fa-plus-circle" aria-hidden="true"></i> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');
            } else {
                // when no roomtype data is present in db 
                $("#divRoomType tbody tr").append('<td class="finalActionsCol"><i class="fa fa-floppy-o editMode" aria-hidden="true"></i></td>');
            }
        },

        AddProperty: function (property) {
            var propertyRequestDto = {};
            propertyRequestDto.Property = {};
            property.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            property.CreatedBy = getCreatedBy();
            // AddProperty by api calling  
            propertyRequestDto.Property = property;
            Notifications.SubscribeActive("on-property-add-success", function (sender, args) {
                window.GuestCheckinManager.GetAllProperty();
            });
            pmsService.AddProperty(propertyRequestDto);
        },

        DeleteBooking: function (bookingId) {
            // DeleteBooking by api calling  
            args.bookingId = bookingId;
            pmsService.DeleteBooking(args);
        },

        UpdateBookingStatus: function (args) {
            // UpdateStatus by api calling  
            pmsService.UpdateStatus(args);
        },

        DeleteProperty: function (propertyId) {
            // DeleteProperty by api calling  
            args.propertyId = propertyId;
            pmsService.DeleteProperty(args);
        },

        DeleteRoomType: function (roomTypeId) {
            // DeleteRoomType by api calling  
            args.roomTypeId = roomTypeId;
            pmsService.DeleteRoomType(args);
        },

        DeleteFloor: function (floorId) {
            // DeleteFloor by api calling  
            args.floorId = floorId;
            pmsService.DeleteFloor(args);
        },

        AddFloor: function (floor) {
            floor.CreatedBy = getCreatedBy();
            floor.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            var floorRequestDto = {};
            floorRequestDto.PropertyFloor = {};
            // AddFloor by api calling  
            floorRequestDto.PropertyFloor = floor;
            pmsService.AddFloor(floorRequestDto);
        },

        UpdateFloor: function (floor) {
            floor.LastUpdatedBy = getCreatedBy();
            floor.LastUpdatedOn = window.GuestCheckinManager.GetCurrentDate();
            // UpdateFloor by api calling 
            var floorRequestDto = {};
            floorRequestDto.PropertyFloor = {};
            floorRequestDto.PropertyFloor = floor;
            pmsService.UpdateFloor(floorRequestDto);
        },

        AddRoomType: function (roomType) {
            roomType.CreatedBy = getCreatedBy();
            roomType.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            var roomTypeRequestDto = {};
            roomTypeRequestDto.RoomType = {};
            // AddRoomType by api calling  
            roomTypeRequestDto.RoomType = roomType;
            pmsService.AddRoomType(roomTypeRequestDto);
        },

        UpdateProperty: function (property) {
            // UpdateProperty by api calling 
            var propertyRequestDto = {};
            propertyRequestDto.Property = {};
            property.LastUpdatedBy = getCreatedBy();
            property.LastUpdatedOn = window.GuestCheckinManager.GetCurrentDate();
            propertyRequestDto.Property = property;
            pmsService.UpdateProperty(propertyRequestDto);
        },

        UpdateRoomType: function (roomType) {
            roomType.LastUpdatedBy = getCreatedBy();
            roomType.LastUpdatedOn = window.GuestCheckinManager.GetCurrentDate();
            // UpdateRoomType by api calling 
            var roomTypeRequestDto = {};
            roomTypeRequestDto.RoomType = {};
            roomTypeRequestDto.RoomType = roomType;
            pmsService.UpdateRoomType(roomTypeRequestDto);
        },

        FindIndex: function (id, settings) {
            var idx = -1;
            if (!settings || settings.length <= 0) return idx;
            for (var i = 0; i < settings.length; i++) {
                if (settings[i].Id === parseInt(id)) {
                    idx = i;
                    return idx;
                }
            }
            return idx;
        },

        FindSetting: function (id, settings) {
            if (!settings || settings.length <= 0) return null;
            for (var i = 0; i < settings.length; i++) {
                if (settings[i].Id !== parseInt(id)) continue;
                return settings[i];
            }
            return null;
        },

        FindUser: function (username, settings) {
            if (!settings || settings.length <= 0) return null;
            for (var i = 0; i < settings.length; i++) {
                if (settings[i].UserName.toLowerCase() !== username.toLowerCase()) continue;
                return settings[i];
            }
            return null;
        },
        FindGuest: function (email, settings) {
            if (!settings || settings.length <= 0) return null;
            for (var i = 0; i < settings.length; i++) {
                if (settings[i].EmailAddress.toLowerCase() !== email.toLowerCase()) continue;
                return settings[i];
            }
            return null;
        },

        OnGridEdit: function (editOn, rowObj, thisObj) {
            $('td:last-child').attr('contenteditable', 'false');
            $('td:last-child').css('background-color', 'transparent');

            if (editOn == false) {
                rowObj.attr('contenteditable', 'true');
                rowObj.css('background-color', 'rgba(255,255,255,0.7)');
                thisObj.removeClass("fa-pencil-square-o");
                thisObj.addClass("fa-floppy-o editMode");
                rowObj[1].focus();
            } else if (editOn == true) {
                rowObj.attr('contenteditable', 'false');
                rowObj.css('background-color', 'transparent');
                thisObj.removeClass("fa-floppy-o editMode");
                thisObj.addClass("fa-pencil-square-o");
            }
        },

        GetRoomTypes: function (propertyId) {
            args.propertyId = propertyId && propertyId > 0 ? propertyId : getPropertyId();
            // get room types by api calling  
            pmsService.GetRoomTypeByProperty(args);
        },

        GetPaymentType: function (propertyId) {
            args.propertyId = propertyId && propertyId > 0 ? propertyId : getPropertyId();
            // get payment types by api calling  
            pmsService.GetPaymentTypeByProperty(args);
        },

        GetFloorsByProperty: function (propertyId) {
            args.propertyId = propertyId;
            // get floor by property by api calling  
            pmsService.GetFloorsByProperty(args);
        },

        DeletePaymentType: function (typeId) {
            // DeletePaymentType by api calling  
            args.typeId = typeId;
            pmsService.DeletePaymentType(args);
        },

        AddPaymentType: function (paymentType) {
            paymentType.CreatedBy = getCreatedBy();
            paymentType.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            var paymentTypeRequestDto = {};
            paymentTypeRequestDto.PaymentType = {};
            // AddPaymentType by api calling  
            paymentTypeRequestDto.PaymentType = paymentType;
            pmsService.AddPaymentType(paymentTypeRequestDto);
        },

        UpdatePaymentType: function (paymentType) {
            paymentType.LastUpdatedBy = getCreatedBy();
            paymentType.LastUpdatedOn = window.GuestCheckinManager.GetCurrentDate();
            // UpdatePaymentType by api calling 
            var paymentTypeRequestDto = {};
            paymentTypeRequestDto.PaymentType = {};
            paymentTypeRequestDto.PaymentType = paymentType;
            pmsService.UpdatePaymentType(paymentTypeRequestDto);
        },

        GetExtraCharge: function (propertyId) {
            args.propertyId = propertyId && propertyId > 0 ? propertyId : getPropertyId();
            // get extra charges by api calling  
            pmsService.GetExtraChargeByProperty(args);
        },

        DeleteExtraCharge: function (id) {
            // DeleteExtraCharge by api calling  
            args.id = id;
            pmsService.DeleteExtraCharge(args);
        },

        AddExtraCharge: function (extracharge) {
            extracharge.CreatedBy = getCreatedBy();
            extracharge.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            var extraChargeRequestDto = {};
            extraChargeRequestDto.ExtraCharge = {};
            // AddExtraCharge by api calling  
            extraChargeRequestDto.ExtraCharge = extracharge;
            pmsService.AddExtraCharge(extraChargeRequestDto);
        },

        UpdateExtraCharge: function (extracharge) {
            extracharge.LastUpdatedBy = getCreatedBy();
            extracharge.LastUpdatedOn = window.GuestCheckinManager.GetCurrentDate();
            // UpdateExtraCharge by api calling 
            var extraChargeRequestDto = {};
            extraChargeRequestDto.ExtraCharge = {};
            extraChargeRequestDto.ExtraCharge = extracharge;
            pmsService.UpdateExtraCharge(extraChargeRequestDto);
        },

        GetTax: function (propertyId) {
            args.propertyId = propertyId && propertyId > 0 ? propertyId : getPropertyId();
            // get tax by api calling  
            pmsService.GetTaxByProperty(args);
        },

        DeleteTax: function (taxId) {
            // DeleteTax by api calling  
            args.taxId = taxId;
            pmsService.DeleteTax(args);
        },

        AddTax: function (tax) {
            tax.CreatedBy = getCreatedBy();
            tax.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            var taxRequestDto = {};
            taxRequestDto.Tax = {};
            // AddTax by api calling  
            taxRequestDto.Tax = tax;
            pmsService.AddTax(taxRequestDto);
        },

        UpdateTax: function (tax) {
            tax.LastUpdatedBy = getCreatedBy();
            tax.LastUpdatedOn = window.GuestCheckinManager.GetCurrentDate();
            // UpdateTax by api calling 
            var taxRequestDto = {};
            taxRequestDto.Tax = {};
            taxRequestDto.Tax = tax;
            pmsService.UpdateTax(taxRequestDto);
        },

        DeleteRateType: function (typeId) {
            // DeleteRateType by api calling  
            args.typeId = typeId;
            pmsService.DeleteRateType(args);
        },

        AddRateType: function (rateType) {
            rateType.CreatedBy = getCreatedBy();
            rateType.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            var rateTypeDto = {};
            rateTypeDto.RateType = {};
            // AddRateType by api calling  
            rateTypeDto.RateType = rateType;
            pmsService.AddRateType(rateTypeDto);
        },

        UpdateRateType: function (existingRateType) {
            existingRateType.LastUpdatedBy = getCreatedBy();
            existingRateType.LastUpdatedOn = window.GuestCheckinManager.GetCurrentDate();
            // UpdateRateType by api calling 
            var rateTypeDto = {};
            rateTypeDto.RateType = {};
            rateTypeDto.RateType = existingRateType;
            pmsService.UpdateRateType(rateTypeDto);
        },

        //Admin Screen Room Methods

        PopulateRoomGrid: function (data) {
            var divRoom = $('#divRoom');
            var roomTemplate = $('#roomTemplate');
            if (!divRoom || !roomTemplate || divRoom.length <= 0 || roomTemplate.length <= 0) return;
            divRoom.html(roomTemplate.render(data));
            $("#divRoom thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
            if (data && data.Rooms && data.Rooms.length > 0) {
                $("#divRoom tbody tr").append('<td class="finalActionsCol"><i class="fa fa-plus-circle" aria-hidden="true"></i> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');
            } else {
                // when no room data is present in db 
                $("#divRoom tbody tr").append('<td class="finalActionsCol"><i class="fa fa-floppy-o editMode" aria-hidden="true"></i></td>');
                window.GuestCheckinManager.FillRoomTypeData($('#ddlRoomTypeAdd'), $('#ddlProperty').val());
                window.GuestCheckinManager.FillFloorData($('#ddlFloorAdd'), $('#ddlProperty').val());
            }
        },

        GetRoomByProperty: function (propertyId) {
            args.propertyId = propertyId && propertyId > 0 ? propertyId : getPropertyId();
            // get rooms by api calling  
            pmsService.GetRoomByProperty(args);
        },

        DeleteRoom: function (roomId) {
            // DeletRoom by api calling  
            args.roomId = roomId;
            pmsService.DeleteRoom(args);
        },

        AddRoom: function (rooms) {
            var roomRequestDto = rooms;
            // AddRoom by api calling  
            pmsService.AddRoom(roomRequestDto);
        },

        UpdateRoom: function (rooms) {
            // UpdateRoom by api calling 
            var roomRequestDto = rooms;
            pmsService.UpdateRoom(roomRequestDto);
        },

        FillRoomData: function (ddlRoomType, ddlRoom, propertyId) {
            if (!ddlRoom || !ddlRoomType || propertyId <= 0) return;
            var rooms = window.GuestCheckinManager.PropertySettingResponseDto.RoomSettings;
            if (!rooms || rooms.length <= 0) {
                Notifications.SubscribeActive("on-room-get-success", function (sender, args) {
                    var data = window.GuestCheckinManager.PropertySettingResponseDto.RoomSettings;
                    window.GuestCheckinManager.BindRoomDdl(ddlRoom, ddlRoomType.value, data, false);
                });
                window.GuestCheckinManager.GetRoomByProperty(propertyId);
            } else {
                window.GuestCheckinManager.BindRoomDdl(ddlRoom, ddlRoomType.value, rooms, false);
            }
        },

        FillPaymentMode: function (ddlPaymentMode, propertyId, callback) {
            if (!ddlPaymentMode || !propertyId || propertyId <= 0) return;

            var paymentTypes = window.GuestCheckinManager.PropertySettingResponseDto.PaymentTypeSettings;
            if (!paymentTypes || paymentTypes.length <= 0) {
                Notifications.SubscribeActive("on-paymenttype-get-success-booking", function (sender, args) {
                    window.GuestCheckinManager.BindPaymentModeDdl(ddlPaymentMode, window.GuestCheckinManager.PropertySettingResponseDto.PaymentTypeSettings);
                    if (callback) callback();
                });
                window.GuestCheckinManager.GetPaymentType(propertyId);
            } else {
                window.GuestCheckinManager.BindPaymentModeDdl(ddlPaymentMode, paymentTypes);
                if (callback) callback();
            }
        },

        FillRoomTypeData: function (ddlRoomType, propertyId) {
            if (!ddlRoomType || !propertyId || propertyId <= 0) return;

            var roomtypes = window.GuestCheckinManager.PropertySettingResponseDto.RoomTypeSettings;
            if (!roomtypes || roomtypes.length <= 0) {
                Notifications.SubscribeActive("on-roomtype-get-success", function (sender, args) {
                    window.GuestCheckinManager.BindRoomTypeDdl(ddlRoomType, window.GuestCheckinManager.PropertySettingResponseDto.RoomTypeSettings);
                });
                window.GuestCheckinManager.GetRoomTypes(propertyId);
            } else {
                window.GuestCheckinManager.BindRoomTypeDdl(ddlRoomType, roomtypes);
            }
        },

        FillFloorData: function (ddlFloor, propertyId) {
            if (!ddlFloor || !propertyId || propertyId <= 0) return;
            //Notifications.SubscribeActive("on-floor-get-success", function (sender, args) {
            //    window.GuestCheckinManager.BindFloorDdl(ddlFloor, window.GuestCheckinManager.PropertySettingResponseDto.FloorSettings);
            //});
            //window.GuestCheckinManager.GetFloorsByProperty(propertyId);

            var floors = window.GuestCheckinManager.PropertySettingResponseDto.FloorSettings;
            if (!floors || floors.length <= 0) {
                Notifications.SubscribeActive("on-floor-get-success", function (sender, args) {
                    window.GuestCheckinManager.BindFloorDdl(ddlFloor, window.GuestCheckinManager.PropertySettingResponseDto.FloorSettings);
                });
                window.GuestCheckinManager.GetFloorsByProperty(propertyId);
            } else {
                window.GuestCheckinManager.BindFloorDdl(ddlFloor, floors);
            }
        },

        FillExpenseCategory: function (ddlExpenseCategory, propertyId, callback) {
            if (!ddlExpenseCategory || !propertyId || propertyId <= 0) return;
            var expensecategory = window.GuestCheckinManager.PropertySettingResponseDto.ExpenseCategorySettings;
            if (!expensecategory || expensecategory.length <= 0 || expensecategory[0].PropertyId != propertyId) {
                var callbackObject= function (sender, args) {
                    window.GuestCheckinManager.BindExpenseCategoryDdl(ddlExpenseCategory, window.GuestCheckinManager.PropertySettingResponseDto.ExpenseCategorySettings);
                    if (callback) callback();
                };
                
                    Notifications.Subscribe("on-expensecategory-get-success", callbackObject);
                window.GuestCheckinManager.GetExpenseCategory(propertyId);
            } else {
                window.GuestCheckinManager.BindExpenseCategoryDdl(ddlExpenseCategory, expensecategory);
                if (callback) callback();
            }
        },

        DeleteRoomRate: function (rateId) {
            // DeleteRoomRate by api calling  
            args.rateId = rateId;
            pmsService.DeleteRoomRate(args);
        },

        AddRoomRate: function (rates) {
            var rateRequestDto = rates;
            // AddRoomRate by api calling  
            pmsService.AddRoomRate(rateRequestDto);
        },

        UpdateRoomRate: function (rates) {
            var rateRequestDto = rates;
            // UpdateRoomRate by api calling 
            pmsService.UpdateRoomRate(rateRequestDto);
        },

        BindFloorDdl: function (ddlFloor, floors) {
            if (!ddlFloor || !floors || floors.length <= 0) return;
            ddlFloor.empty();
            ddlFloor.append(new Option("Select Floor", "-1"));
            for (var i = 0; i < floors.length; i++) {
                ddlFloor.append(new Option(floors[i].FloorNumber, floors[i].Id));
            }
        },
        BindExpenseCategoryDdl: function (ddlExpenseCategory, expensecategories) {
            if (ddlExpenseCategory) {
                ddlExpenseCategory.empty();
                ddlExpenseCategory.append(new Option("Select Category", "-1"));
            }
            if (!ddlExpenseCategory || !expensecategories || expensecategories.length <= 0)
                return;
            
            for (var i = 0; i < expensecategories.length; i++) {
                ddlExpenseCategory.append(new Option(expensecategories[i].Description, expensecategories[i].Id));
            }
        },

        SetPropertyLogo: function (propertyId, imageCntrl) {
            var propertyData = $.parseJSON(window.PmsSession.GetItem("allprops"));
            if (!propertyData || propertyData.length <= 0 || propertyId === "-1") return;
            var idx = window.GuestCheckinManager.CheckIfKeyPresent(parseInt(propertyId), propertyData);
            if (idx < 0) return;
            var selectedPropertyInfo = propertyData[idx];

            imageCntrl.css('visibility', 'visible');
            imageCntrl.addClass('photo-added');
            var logoPath = selectedPropertyInfo.LogoPath;
            var url = '';
            if (logoPath) {
                if (logoPath.indexOf('ftp') >= 0) {
                    url = logoPath;
                } else {
                    var fName = extractFileNameFromFilePath(logoPath);
                    if (fName) {
                        url = window.apiBaseUrl + window.uploadDirectory + "/" + fName;
                    }
                }
            }

            if (url) {
                imageCntrl.attr('src', url);
            } else {
                imageCntrl.css('visibility', 'hidden');
                imageCntrl.removeClass('photo-added');
            }
        },

        PopulateGuestDetails: function (guest) {
            $('#fName').val(guest.FirstName);
            $('#lName').val(guest.LastName);
            $('#phone').val(guest.MobileNumber);
            $('#email').val(guest.EmailAddress);
            $('#dob').val(formatAMPM(guest.DOB.replace('T', ' ')));
            $("#ddlInitials [value=" + guest.Gender + "]").attr("selected", "true");
            $('#imgPhoto').css('visibility', 'visible');
            $('#imgPhoto').addClass('photo-added');
            $('#imgAdditionalPhoto').css('visibility', 'visible');
            $('#imgAdditionalPhoto').addClass('photo-added');
            var url = '';
            if (guest.PhotoPath.indexOf('ftp') >= 0) {
                url = guest.PhotoPath;
            } else {
                var fName = extractFileNameFromFilePath(guest.PhotoPath);
                if (fName) {
                    url = window.apiBaseUrl + window.uploadDirectory + "/" + fName;
                }
            }
            if (url) {
                $('#imgPhoto').attr('src', url);
            } else {
                $('#imgPhoto').css('visibility', 'hidden');
                $('#imgPhoto').removeClass('photo-added');
            }
        },

        ClearExistingSessionStorage: function () {
            pmsSession.RemoveItem("propertyid");
            pmsSession.RemoveItem("roomtypedata");
            pmsSession.RemoveItem("roomratedata");
            //            pmsSession.RemoveItem("roomdata");
            pmsSession.RemoveItem("propertyrooms");
            pmsSession.RemoveItem("bookingId");
            pmsSession.RemoveItem("dtcheckin");
            pmsSession.RemoveItem("dtcheckout");
            pmsSession.RemoveItem("roomtypeid");
            pmsSession.RemoveItem("roomid");
        },

        ValidateInputs: function () {
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
            var rateType = $('#rateTypeDdl').val();
            var roomId = $('#roomddl').val();
            var city = $('#ddlCity').val();
            var state = $('#ddlState').val();
            var country = $('#ddlCountry').val();
            var baseRoomCharge = $("#baseRoomCharge");
            var totalRoomCharge = $('#totalRoomCharge');

            if (baseRoomCharge.length > 0 && (baseRoomCharge.val().trim() === "" || baseRoomCharge.val() <= 0)) {
                alert('Room charge is not configured for your selection. Please contact administrator.');
                baseRoomCharge.focus();
                return false;
            }

            if (totalRoomCharge.length > 0 && (totalRoomCharge.val().trim() === "" || totalRoomCharge.val() <= 0)) {
                alert('Please contact administrator.');
                totalRoomCharge.focus();
                return false;
            }

            var noOfHours = window.GuestCheckinManager.GetSelectedCheckoutHrs();
            if ($('#hourCheckin')[0].checked && parseInt(noOfHours) <= 0) {
                alert("Please select checkout hours.");
                return false;
            }

            // check checkin date 
            if (!dateFrom || dateFrom.trim() === "" || dateFrom.length <= 0) {
                alert("Please select checkin date");
                $('#dateFrom').focus();
                return false;
            }

            // check checkout date 
            if (!dateTo || dateTo.trim() === "" || dateTo.length <= 0) {
                alert("Please select checkout date");
                $('#dateTo').focus();
                return false;
            }

            if (!roomType || roomType === '-1') {
                alert("Please select room type");
                return false;
            }

            if (!rateType || rateType === '-1') {
                alert("Please select rate type");
                return false;
            }

            if (!roomId || roomId === '-1') {
                alert("Please select room number");
                return false;
            }

            // check adult or child value
            if ((!adult || adult <= 0) && (!child || child <= 0)) {
                alert("Please select atleast an adult or child");
                return false;
            }

            // check first name 
            if (!fname || fname.trim() === "" || fname.length <= 0) {
                alert("Please enter the first name");
                $('#fName').focus();
                return false;
            }
            // check last name
            if (!lname || lname.trim() === "" || lname.length <= 0) {
                alert("Please enter the last name");
                $('#lName').focus();
                return false;
            }
            // check phone number
            //if (!phNumber || phNumber.length <= 0) {
            //    alert("Please enter phone number");
            //    $('#phone').focus();
            //    return false;
            //}


            if (!country || country === '-1') {
                alert("Please select country");
                return false;
            }

            if (!state || state === '-1') {
                alert("Please select state");
                return false;
            }

            if (!city || city === '-1') {
                alert("Please select city");
                return false;
            }

            // check zipcode
            if (!zipCode || zipCode.length <= 0) {
                alert("Please enter zip code");
                $('#zipCode').focus();
                return false;
            }

            var emailId = $("#email").val();
            var validEmailIdRegex = new RegExp(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/);
            // check email 
            if (emailId && emailId.trim() !== "" && emailId.length > 0) {
                var testemail = validEmailIdRegex.test(emailId);
                if (testemail !== true) {
                    alert("Please enter valid email format.");
                    $('#email').focus();
                    return false;
                }
            }

            if (!guestIdType || guestIdType === '-1') {
                alert("Please select Type Of ID.");
                return false;
            }
            // check guest id details
            if (!idDetails || idDetails.trim() === "" || idDetails.length <= 0) {
                alert("Please enter ID number");
                $('#idDetails').focus();
                return false;
            }

            // check id expiry details 
            //if (!idExpiry || idExpiry.length <= 0) {
            //    alert("Please enter guest ID expiry details");
            //    $('#idExpiry').focus();
            //    return false;
            //}
            return true;
        },

        GetCurrentDate: function () {
            // date format yyyy/mm/dd
            var dt = new Date();
            var month = dt.getMonth() + 1;
            var day = dt.getDate();
            var dateOutput = dt.getFullYear() + '-' +
                (month < 10 ? '0' : '') + month + '-' +
                (day < 10 ? '0' : '') + day;

            var time = dt.getHours() + ":" + dt.getMinutes() + ":" + dt.getSeconds();
            return dateOutput + ' ' + time;
        },

        GetDays: function (startDate, endDate) {
            var oneDay = 1000 * 60 * 60 * 24;
            var fromDate = new Date(startDate);
            var toDate = new Date(endDate);
            fromDate.setHours(0, 0, 0);
            toDate.setHours(0, 0, 0);

            //var dateDiff = Math.abs(toDate.getTime() - fromDate.getTime());
            var dateDiff = toDate.getTime() - fromDate.getTime();
            var noOfDays = Math.ceil(dateDiff / oneDay);
            return noOfDays;
        },
        AddDay: function (date, days) {
            var d = new Date(date);
            d.setDate(d.getDate() + days);
            var month = d.getMonth() + 1;
            var day = d.getDate();
            var dateOutput = d.getFullYear() + '-' +
                (month < 10 ? '0' : '') + month + '-' +
                (day < 10 ? '0' : '') + day;
            return dateOutput;
        },

        PrepareFolioData: function () {
            var data = {};
            data.CreatedOn = formatAMPM(window.GuestCheckinManager.GetCurrentDate());
            data.Address = $("#address").val();
            data.GuestName = $("#lName").val() + ", " + $("#fName").val();
            //TODO remove hardcoded value
            data.GuestCount = 1;
            data.City = $("#ddlCity option:selected").text();
            data.State = $("#ddlState option:selected").text();
            data.Zip = $("#zipCode").val();
            data.AdditionalGuest = $("#adLName").val() + ", " + $("#adFName").val();
            data.Room = $("#roomddl option:selected").text()
            data.RoomType = $("#roomTypeDdl option:selected").text();
            data.Arrival = $("#dateFrom").val();
            data.Departure = $("#dateTo").val();
            data.Phone = $("#phone").val();
            data.StayDays = window.GuestCheckinManager.GetDays(data.Arrival, data.Departure);
            data.Folio = "N/A";
            data.Rate = $("#rateTypeDdl option:selected").text();
            data.TotalRoomCharges = $('#totalRoomCharge').val();
            data.Credit = 0;
            data.Taxes = [];
            data.Taxes = prepareTaxForPrint(parseFloat(data.TotalRoomCharges));
            data.PaymentDetails = [];
            var totalAmount = $('#total') ? $('#total').val() : 0;
            data.PaymentDetails = preparePaymentDetailForPrint(totalAmount);
            data = preparePropertyData(data);
            data.TotalAmount = totalAmount;
            data.TotalBalance = $("#balance").val();
            data.InvoiceItems = [];
            data.InvoiceItems = prepareOtherCharges();
            return data;
        },

        PrepareReceiptData: function () {
            var data = {};
            data.CreatedOn = formatAMPM(window.GuestCheckinManager.GetCurrentDate()).split(' ')[0];
            data.Address = $("#address").val();
            data.GuestName = $("#lName").val() + ", " + $("#fName").val();
            //TODO remove hardcoded value
            data.GuestCount = 1;
            data.City = $("#ddlCity option:selected").text();
            data.State = $("#ddlState option:selected").text();
            data.Zip = $("#zipCode").val();
            data.AdditionalGuest = $("#adLName").val() + ", " + $("#adFName").val();
            data.Room = $("#roomddl option:selected").text()
            data.RoomType = $("#roomTypeDdl option:selected").text();
            data.Arrival = $("#dateFrom").val();
            data.Departure = $("#dateTo").val();
            data.Phone = $("#phone").val();
            data.StayDays = window.GuestCheckinManager.GetDays(data.Arrival, data.Departure);
            data.Folio = "N/A";
            data.Rate = $("#rateTypeDdl option:selected").text();
            data.TotalRoomCharges = $('#totalRoomCharge').val();
            data.Credit = 0;
            data.Taxes = [];
            data.Taxes = prepareTaxForPrint(parseFloat(data.TotalRoomCharges));
            data.PaymentDetails = [];
            var totalAmount = $('#total') ? $('#total').val() : 0;
            data.PaymentDetails = preparePaymentDetailForPrint(totalAmount);
            data = preparePropertyData(data);
            data.TotalAmount = totalAmount;
            data.TotalBalance = $("#balance").val();
            data.InvoiceItems = [];
            data.InvoiceItems = prepareOtherCharges();

            var balance = 0;
            for (var i = 0; i < data.InvoiceItems.length; i++) {
                if (data.InvoiceItems[i].ItemType == "roomcharges")
                    data.InvoiceItems[i].Balance = balance = (parseFloat(balance) + parseFloat(data.InvoiceItems[i].ItemValue)).toFixed(2);
            }
            for (var i = 0; i < data.Taxes.length; i++) {
                data.Taxes[i].Balance = balance = (parseFloat(balance) + parseFloat(data.Taxes[i].TaxValue)).toFixed(2);
            }
            for (var i = 0; i < data.InvoiceItems.length; i++) {
                if (data.InvoiceItems[i].ItemType == "otheritem")
                    data.InvoiceItems[i].Balance = balance = (parseFloat(balance) + parseFloat(data.InvoiceItems[i].ItemValue)).toFixed(2);
            }
            for (var i = 0; i < data.PaymentDetails.length; i++) {
                data.PaymentDetails[i].Balance = balance = (parseFloat(balance) - parseFloat(data.PaymentDetails[i].PaymentValue)).toFixed(2);
            }
            return data;
        },

        PopulatePrintData: function (printType) {
            var divToPrint = $('#divToPrint');
            var data = {};
            var printTemplate = '';
            divToPrint.html('');
            printTemplate = printType === "receipt" ? $('#receiptTemplate') : $('#folioTemplate');
            if (printType === "receipt") {
                data = window.GuestCheckinManager.PrepareReceiptData();
            } else {
                data = window.GuestCheckinManager.PrepareFolioData();
            }
            if (data && divToPrint && divToPrint.length > 0
                && printTemplate && printTemplate.length > 0) {
                divToPrint.html(printTemplate.render(data));
                return divToPrint[0].innerHTML;
            }
            return "No data is available for printing";
        },

        GetSelectedCheckoutHrs: function () {
            var noOfHours = -1;
            if ($("#hoursComboBox option:selected").text().indexOf('-') >= 0) {
                noOfHours = parseInt($("#hoursComboBox option:selected").text().split('-')[0]);
            }
            return noOfHours;
        },

        UpdateRoomStatus: function (args) {
            // UpdateRoomStatus by api calling  
            pmsService.UpdateRoomStatus(args);
        },

        GetBookingTransaction: function (requestDto) {
            // GetBookingTransaction by api calling  
            pmsService.GetBookingTransaction(requestDto);
        },

        GetQueryStringParams: function (sParam) {
            var sPageURL = window.location.search.substring(1);
            var sURLVariables = sPageURL.split('&');
            for (var i = 0; i < sURLVariables.length; i++) {
                var sParameterName = sURLVariables[i].split('=');
                if (sParameterName[0] == sParam) {
                    return sParameterName[1];
                }
            }
        },

        GetExpenseCategory: function (propertyId) {
            args.propertyId = propertyId && propertyId > 0 ? propertyId : getPropertyId();
            // get payment types by api calling  
            pmsService.GetExpenseCategoryByProperty(args);
        },

        DeleteExpenseCategory: function (typeId) {
            // DeleteExpenseCategory by api calling  
            args.typeId = typeId;
            pmsService.DeleteExpenseCategory(args);
        },

        AddExpenseCategory: function (expenseCategory) {
            expenseCategory.CreatedBy = getCreatedBy();
            expenseCategory.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            var expenseCategoryRequestDto = {};
            expenseCategoryRequestDto.ExpenseCategory = {};
            // AddexpenseCategory by api calling  
            expenseCategoryRequestDto.ExpenseCategory = expenseCategory;
            pmsService.AddExpenseCategory(expenseCategoryRequestDto);
        },

        UpdateExpenseCategory: function (expenseCategory) {
            expenseCategory.LastUpdatedBy = getCreatedBy();
            expenseCategory.LastUpdatedOn = window.GuestCheckinManager.GetCurrentDate();
            // UpdateExpenseCategory by api calling 
            var expenseCategoryRequestDto = {};
            expenseCategoryRequestDto.ExpenseCategory = {};
            expenseCategoryRequestDto.ExpenseCategory = expenseCategory;
            pmsService.UpdateExpenseCategory(expenseCategoryRequestDto);
        },

        PopulateExpenseCategoryGrid: function (data) {
            var divExpenseCategory = $('#divExpenseCategory');
            var expensecategoryTemplate = $('#expensecategoryTemplate');
            if (!divExpenseCategory || !expensecategoryTemplate || divExpenseCategory.length <= 0 || expensecategoryTemplate.length <= 0) return;
            divExpenseCategory.html(expensecategoryTemplate.render(data));
            $("#divExpenseCategory thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
            if (data && data.ExpenseCategories && data.ExpenseCategories.length > 0) {
                $("#divExpenseCategory tbody tr").append('<td class="finalActionsCol"><i class="fa fa-plus-circle" aria-hidden="true"></i> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');
            } else {
                // when no expensecategory data is present in db 
                $("#divExpenseCategory tbody tr").append('<td class="finalActionsCol"><i class="fa fa-floppy-o editMode" aria-hidden="true"></i></td>');
            }
        },

        GetExpense: function (args) {
            pmsService.GetExpenseBySearch(args);
        },

        DeleteExpense: function (typeId) {
            // DeleteExpense by api calling  
            args.typeId = typeId;
            pmsService.DeleteExpense(args);
        },

        AddExpense: function (expense) {
            expense.CreatedBy = getCreatedBy();
            expense.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            var expenseRequestDto = {};
            expenseRequestDto.Expense = {};
            // Addexpense by api calling  
            expenseRequestDto.Expense = expense;
            pmsService.AddExpense(expenseRequestDto);
        },

        UpdateExpense: function (expense) {
            expense.LastUpdatedBy = getCreatedBy();
            expense.LastUpdatedOn = window.GuestCheckinManager.GetCurrentDate();
            // UpdateExpense by api calling 
            var expenseRequestDto = {};
            expenseRequestDto.Expense = {};
            expenseRequestDto.Expense = expense;
            pmsService.UpdateExpense(expenseRequestDto);
        },

        PopulateExpenseGrid: function (data) {
            var divExpense = $('#divExpense');
            divExpense.empty();
            var expenseTemplate = $('#expenseTemplate');
            if (!divExpense || !expenseTemplate || divExpense.length <= 0 || expenseTemplate.length <= 0) return;
            divExpense.html(expenseTemplate.render(data));
            $("#divExpense thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
            if (data && data.Expenses && data.Expenses.length > 0) {
                $("#divExpense tbody tr").append('<td class="finalActionsCol"><i class="fa fa-plus-circle" aria-hidden="true"></i> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');
            } else {
                // when no expense data is present in db 
                $("#divExpense tbody tr").append('<td class="finalActionsCol"><i class="fa fa-floppy-o editMode" aria-hidden="true"></i></td>');
                window.GuestCheckinManager.FillExpenseCategory($('#ddlExpenseCategoryAdd'), $('#ddlProperty').val());
                window.GuestCheckinManager.FillPaymentMode($('#ddlPaymentTypeAdd'), $('#ddlProperty').val());
            }
            $('.gridDatePicker').datetimepicker({ format: 'MM/DD/YYYY' });
            $('.decimal').moneyFormat();
        },

        GetShiftReport: function (requestDto) {
            pmsService.GetShiftReport(requestDto);
        },

        GetConsolidatedShiftReport: function (requestDto) {
            pmsService.GetConsolidatedShiftReport(requestDto);
        },

        GetManagerReport: function (requestDto) {
            pmsService.GetManagerReport(requestDto);
        },

        GetConsolidatedManagerDataPreviousMonth: function (requestDto) {
            pmsService.GetConsolidatedManagerDataPreviousMonth(requestDto);
        },
        GetConsolidatedManagerDataPreviousYear: function (requestDto) {
            pmsService.GetConsolidatedManagerDataPreviousYear(requestDto);
        },

        PopulateShiftReportGrid: function (data) {
            var divShiftReport = $('#divShiftReport');
            var shiftReportTemplate = $('#shiftReportTemplate');
            if (!divShiftReport || !shiftReportTemplate || divShiftReport.length <= 0 || shiftReportTemplate.length <= 0) return;
            divShiftReport.html(shiftReportTemplate.render(data));
            $('.decimal').moneyFormat();
        },
        PopulateConsolidatedShiftReportGrid: function (data) {
            var divConsolidatedShiftReport = $('#divConsolidatedShiftReport');
            var consolidatedshiftReportTemplate = $('#consolidatedshiftReportTemplate');
            if (!divConsolidatedShiftReport || !consolidatedshiftReportTemplate ||
                divConsolidatedShiftReport.length <= 0 || consolidatedshiftReportTemplate.length <= 0) return;
            divConsolidatedShiftReport.html(consolidatedshiftReportTemplate.render(data));
            $('.decimal').moneyFormat();
        },
        PopulateManagerReportGrid: function (data) {
            var divManagerReport = $('#divManagerReport');
            var managerReportTemplate = $('#managerReportTemplate');
            if (!divManagerReport || !managerReportTemplate || divManagerReport.length <= 0 || managerReportTemplate.length <= 0) return;
            divManagerReport.html(managerReportTemplate.render(data));
            $('.decimal').moneyFormat();
        },
        PopulateConsolidatedManagerReportGridMonth: function (data) {
            var divConsolidatedManagerReportMonth = $('#divConsolidatedManagerReportMonth');
            var consolidatedManagerReportTemplate = $('#consolidatedManagerReportTemplate');
            if (!divConsolidatedManagerReportMonth || !consolidatedManagerReportTemplate || divConsolidatedManagerReportMonth.length <= 0 || consolidatedManagerReportTemplate.length <= 0) return;
            divConsolidatedManagerReportMonth.html(consolidatedManagerReportTemplate.render(data));
            $('.decimal').moneyFormat();
        },

        PopulateConsolidatedManagerReportGridYear: function (data) {
            var divConsolidatedManagerReportYear = $('#divConsolidatedManagerReportYear');
            var consolidatedManagerReportTemplate = $('#consolidatedManagerReportTemplate');
            if (!divConsolidatedManagerReportYear || !consolidatedManagerReportTemplate || divConsolidatedManagerReportYear.length <= 0 || consolidatedManagerReportTemplate.length <= 0) return;
            divConsolidatedManagerReportYear.html(consolidatedManagerReportTemplate.render(data));
            $('.decimal').moneyFormat();
        },

        DeleteUser: function (userId) {
            // DeleteExpense by api calling  
            args.userId = userId;
            pmsService.DeleteUser(args);
        },

        AddUser: function (user) {
            user.CreatedBy = getCreatedBy();
            user.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            var userRequestDto = {};
            userRequestDto.User = {};
            // Addexpense by api calling  
            userRequestDto.User = user;
            Notifications.SubscribeActive("on-user-add-success", function (sender, args) {
                window.GuestCheckinManager.GetAllUser();
            });
            pmsService.AddUser(userRequestDto);
        },

        UpdateUser: function (user) {
            user.LastUpdatedBy = getCreatedBy();
            user.LastUpdatedOn = window.GuestCheckinManager.GetCurrentDate();
            // UpdateExpense by api calling 
            var userRequestDto = {};
            userRequestDto.User = {};
            userRequestDto.User = user;
            Notifications.SubscribeActive("on-user-add-success", function (sender, args) {
                window.GuestCheckinManager.GetAllUser();
            });
            pmsService.UpdateUser(userRequestDto);
        },

        GetAllUser: function () {
            pmsService.GetAllUser(args);
        },

        PopulateUserGrid: function (data) {
            var divUser = $('#divUser');
            var userTemplate = $('#userTemplate');
            if (!divUser || !userTemplate) return;
            divUser.html(userTemplate.render(data));
            $("#divUser thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
            $("#divUser tbody tr").append('<td class="finalActionsCol"><i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');
        },
        BindPropertyPanel: function (ulProperty, properties) {
            if (!ulProperty || !properties || properties.length <= 0) return;

            ulProperty.empty();
            for (var i = 0; i < properties.length; i++) {
                ulProperty.append('<li id="' + properties[i].Id + '">' + properties[i].PropertyName + '</li>');
            }
        },
        RemovePropertyPanel: function (ulProperty, properties) {
            if (!ulProperty || !properties || properties.length <= 0) return;
            for (var i = 0; i < properties.length; i++) {
                ulProperty.find('li#' + properties[i].Id).remove();
            }
        },
        GetPropertyByUserId: function (userId) {
            args.userId = userId;
            // get property by api calling 
            pmsService.GetPropertyByUserId(args);
        },
        GetAllFunctionality: function () {
            if (window.GuestCheckinManager.PropertySettingResponseDto.AllFunctionalitiesSettings &&
                window.GuestCheckinManager.PropertySettingResponseDto.AllFunctionalitiesSettings.length > 0) {
                var panelFunctionality = $('#panelFunctionality');
                if (panelFunctionality) {
                    window.GuestCheckinManager.BindFunctionalityPanel($('#panelFunctionality .left ul'),
                        window.GuestCheckinManager.PropertySettingResponseDto.AllFunctionalitiesSettings);
                }
            }
            else {
                pmsService.GetAllFunctionality(args);
                Notifications.SubscribeActive("on-functionality-get-success", function (sender, args) {
                    var panelFunctionality = $('#panelFunctionality');
                    if (panelFunctionality) {
                        window.GuestCheckinManager.BindFunctionalityPanel($('#panelFunctionality .left ul'),
                        window.GuestCheckinManager.PropertySettingResponseDto.AllFunctionalitiesSettings);
                    }
                });
            }
        },
        BindFunctionalityPanel: function (ulFunctionality, functionalities) {
            if (!ulFunctionality || !functionalities || functionalities.length <= 0) return;

            ulFunctionality.empty();
            for (var i = 0; i < functionalities.length; i++) {
                ulFunctionality.append('<li id="' + functionalities[i].Id + '">' + functionalities[i].Functionality1 + '</li>');
            }
        },
        RemoveFunctionalityPanel: function (ulFunctionality, functionalities) {
            if (!ulFunctionality || !functionalities || functionalities.length <= 0) return;
            for (var i = 0; i < functionalities.length; i++) {
                ulFunctionality.find('li#' + functionalities[i].Id).remove();
            }
        },
        GetMyFunctionality: function () {
            if (window.GuestCheckinManager.LocalUserDto.Functionalities == null
                 || window.GuestCheckinManager.LocalUserDto.Functionalities.length == 0) {

                args.userId = window.PmsSession.GetItem("userid");
                pmsService.GetFunctionalityByUserId(args);

                Notifications.SubscribeActive("on-functionality-user-get-success", function (sender, args) {
                    window.GuestCheckinManager.LocalUserDto.Functionalities =
                        window.GuestCheckinManager.PropertySettingResponseDto.FunctionalitiesSettings;

                    //menu
                    window.GuestCheckinManager.MenuByUserFunctionality();
                });
            }
            else {
                // menu
                window.GuestCheckinManager.MenuByUserFunctionality();
            }

        },
        GetFunctionalityByUserId: function (userId) {
            args.userId = userId;
            pmsService.GetFunctionalityByUserId(args);
        },
        MenuByUserFunctionality: function () {
            window.GuestCheckinManager.IsFunctionalityAllow();

            for (var i = 0; i < window.GuestCheckinManager.LocalUserDto.Functionalities.length; i++) {
                $('#side-nav li a[href*="' + window.GuestCheckinManager.LocalUserDto.Functionalities[i].Description + '" i]').addClass('my-function');
            }
            $('#side-nav li a:not([href="#"]):not(.my-function)').each(function () {
                $(this).parent().remove();
            });
            $('#side-nav li ul').each(function () {
                if ($(this).children().length == 0) {
                    $(this).parent().remove();
                }
            });
            $('#side-nav').show();
        },
        InsertUserAccess: function (args) {
            args.CreatedBy = getCreatedBy();
            pmsService.InsertUserAccess(args);
        },
        IsFunctionalityAllow: function () {
            var valid = false;

            //Test
            var testAccess = "Booking/Checkin";
            if (window.location.href.toLowerCase().indexOf(testAccess.toLowerCase()) >= 0)
                return;

            for (var i = 0; i < window.GuestCheckinManager.LocalUserDto.Functionalities.length; i++) {
                if (window.location.href.toLowerCase().indexOf(window.GuestCheckinManager.LocalUserDto.Functionalities[i].Description.toLowerCase()) >= 0) {
                    valid = true;
                    return;
                }
            }
            if (!valid) {
                // Temp comment for user access 
                // window.location.href = window.webBaseUrl;
            }
        },
        GetGuestSummary: function (args) {
            pmsService.GetGuestSummary(args);
        },
        PopulateGuestSummaryGrid: function (data) {
            var guestSummary = $('#guestSummary');
            var guestSummaryTemplate = $('#guestSummaryTemplate');
            if (!guestSummary || !guestSummaryTemplate || guestSummary.length <= 0 || guestSummaryTemplate.length <= 0) return;
            guestSummary.html(guestSummaryTemplate.render(data));
        },
        DeleteGuest: function (guestId) {
            args.guestId = guestId;
            pmsService.DeleteGuest(args);
        },

        AddGuest: function (guest) {
            guest.CreatedBy = getCreatedBy();
            guest.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            var guestRequestDto = {};
            guestRequestDto.Guest = {};
            // Addexpense by api calling  
            guestRequestDto.Guest = guest;
            Notifications.SubscribeActive("on-guest-add-success", function (sender, args) {
                window.GuestCheckinManager.GetGuest();
            });
            pmsService.AddGuest(guestRequestDto);
        },

        UpdateGuest: function (guest) {
            guest.LastUpdatedBy = getCreatedBy();
            guest.LastUpdatedOn = window.GuestCheckinManager.GetCurrentDate();

            var guestRequestDto = {};
            guestRequestDto.Guest = {};
            guestRequestDto.Guest = guest;
            Notifications.SubscribeActive("on-guest-add-success", function (sender, args) {
                window.GuestCheckinManager.GetGuest();
            });
            pmsService.UpdateGuest(guestRequestDto);
        },

        GetGuest: function () {
            pmsService.GetGuest(args);
        },

        PopulateGuestGrid: function (data) {
            var divGuest = $('#divGuest');
            var guestTemplate = $('#guestTemplate');
            if (!divGuest || !guestTemplate) return;
            divGuest.html(guestTemplate.render(data));
            $("#divGuest thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
            $("#divGuest tbody tr").append('<td class="finalActionsCol"><i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');
        },
        PopulateGuestMasterDetail: function (guest) {
            $('#password').val(guest.Password);
            $('#firstName').val(guest.FirstName);
            $('#lastName').val(guest.LastName);
            $('#mobileNumber').val(guest.MobileNumber);
            $('#emailAddress').val(guest.EmailAddress);
            $('#dob').val(guest.DOB.split('T')[0]);
            $('#ddlGender').val(guest.Gender);

            // Address Info
            $('#address').val(guest.Address1);
            $('#zipCode').val(guest.ZipCode);
            $('#ddlCountry').val(guest.Country.Id);
            if (guest.Country && guest.Country.Id) {
                $('#ddlCountry').val(guest.Country.Id);
                gcm.BindStateDdl(guest.Country.Id, $('#ddlState'));

            }
            if (guest.State && guest.State.Id) {
                $('#ddlState').val(guest.State.Id);
                gcm.BindStateDdl(guest.Country.Id, $('#ddlState'));
            }
            gcm.BindCityDdl(guest.State.Id, $('#ddlCity'));
            $('#ddlState').val(guest.State.Id);
            $('#ddlCity').val(guest.City.Id);

            $('#imgPhoto').css('visibility', 'visible');
            $('#imgPhoto').addClass('photo-added');
            $('#imgAdditionalPhoto').css('visibility', 'visible');
            $('#imgAdditionalPhoto').addClass('photo-added');
            var url = '';
            if (guest.PhotoPath.indexOf('ftp') >= 0) {
                url = guest.PhotoPath;
            } else {
                var fName = extractFileNameFromFilePath(guest.PhotoPath);
                if (fName) {
                    url = window.apiBaseUrl + window.uploadDirectory + "/" + fName;
                }
            }
            if (url) {
                $('#imgPhoto').attr('src', url);
            } else {
                $('#imgPhoto').css('visibility', 'hidden');
                $('#imgPhoto').removeClass('photo-added');
            }

            if (guest.PhotoPath != '') {
                $('#lblLogo').addClass('photo_submit--image');
                $('#uploadPhoto').prop('disabled', 'disabled');
            }
        },
        PopulateInvoiceDetail: function () {
            var data = {};
            data.CreatedOn = formatAMPM(window.GuestCheckinManager.GetCurrentDate()).split(' ')[0];
            data.Address = $("#address").val();
            data.GuestName = $("#lName").val() + ", " + $("#fName").val();
            //TODO remove hardcoded value
            data.GuestCount = 1;
            data.City = $("#ddlCity option:selected").text();
            data.State = $("#ddlState option:selected").text();
            data.Zip = $("#zipCode").val();
            data.AdditionalGuest = $("#adLName").val() + ", " + $("#adFName").val();
            data.Room = $("#roomddl option:selected").text()
            data.RoomType = $("#roomTypeDdl option:selected").text();
            data.Arrival = $("#dateFrom").val();
            data.Departure = $("#dateTo").val();
            data.Phone = $("#phone").val();
            data.StayDays = window.GuestCheckinManager.GetDays(data.Arrival, data.Departure);
            data.Folio = "N/A";
            data.Rate = $("#rateTypeDdl option:selected").text();
            data.TotalRoomCharges = $('#totalRoomCharge').val();
            data.Credit = 0;
            data.Nights = [];
            data = preparePropertyData(data);
            var row = window.GuestCheckinManager.invoiceData.Invoice;
            for (var i = 0; i < data.StayDays; i++) {
                var displayDate = window.GuestCheckinManager.AddDay(data.Arrival, i);
                data.Nights[i] = {};
                data.Nights[i].No = i;
                data.Nights[i].Taxes = [];
                data.Nights[i].PaymentDetails = [];
                data.Nights[i].InvoiceItems = [];

                //Room charges
                var totalRoomCharge = {};
                totalRoomCharge.ItemName = $('#totalRoomCharge')[0].name;
                totalRoomCharge.ItemValue = (parseFloat($("#totalRoomCharge").val()) / data.StayDays).toFixed(2);
                totalRoomCharge.IsActive = true;
                totalRoomCharge.CreatedOn = displayDate;
                totalRoomCharge.CreatedBy = getCreatedBy();
                totalRoomCharge.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;
                totalRoomCharge.ItemType = 'roomcharges';
                data.Nights[i].InvoiceItems.push(totalRoomCharge);

                //Other Item
                for (var j = 0; j < row.Tax.length; j++) {
                    if (!row.Tax[j].IsDefaultCharges && (row.Tax[j].CreatedOn.split('T')[0] == displayDate
                        || (i == data.StayDays - 1 &&
                        row.Tax[j].CreatedOn.split('T')[0] == window.GuestCheckinManager.AddDay(displayDate, 1)))) {
                        var otherTax = {};
                        otherTax.ItemName = row.Tax[j].TaxName;
                        otherTax.ItemValue = row.Tax[j].Value.toFixed(2);
                        otherTax.IsActive = true;
                        otherTax.CreatedOn = row.Tax[j].CreatedOn;
                        otherTax.CreatedBy = getCreatedBy();
                        otherTax.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;
                        otherTax.ItemType = 'otheritem';
                        //otherTax.InvoiceId = 1038;
                        data.Nights[i].InvoiceItems.push(otherTax);
                    }
                    else if (row.Tax[j].IsDefaultCharges && row.Tax[j].IsTaxIncluded) {
                        var tax = {};
                        tax.TaxShortName = row.Tax[j].TaxName;
                        tax.TaxAmount = row.Tax[j].Value.toFixed(2);
                        tax.TaxValue = (parseFloat(row.Tax[j].Amount) / data.StayDays).toFixed(2);
                        tax.IsActive = true;
                        tax.CreatedOn = row.Tax[j].CreatedOn;
                        tax.CreatedBy = getCreatedBy();
                        tax.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;
                        data.Nights[i].Taxes.push(tax);
                    }
                }
                for (var j = 0; j < row.InvoicePaymentDetails.length; j++) {
                    if (row.InvoicePaymentDetails[j].CreatedOn.split('T')[0] == displayDate
                        || (i == data.StayDays - 1 &&
                        row.InvoicePaymentDetails[j].CreatedOn.split('T')[0] == window.GuestCheckinManager.AddDay(displayDate, 1))) {
                        var payment = {};
                        payment.PaymentMode = row.InvoicePaymentDetails[j].PaymentMode;
                        payment.PaymentValue = row.InvoicePaymentDetails[j].PaymentValue;
                        payment.IsActive = true;
                        payment.CreatedOn = row.InvoicePaymentDetails[j].CreatedOn
                        payment.CreatedBy = getCreatedBy();
                        payment.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;
                        data.Nights[i].PaymentDetails.push(payment);
                    }
                }
            }


            var balance = 0;
            for (var j = 0; j < data.Nights.length; j++) {
                for (var i = 0; i < data.Nights[j].InvoiceItems.length; i++) {
                    if (data.Nights[j].InvoiceItems[i].ItemType == "roomcharges")
                        data.Nights[j].InvoiceItems[i].Balance = balance = (parseFloat(balance) + parseFloat(data.Nights[j].InvoiceItems[i].ItemValue)).toFixed(2);
                }
                for (var i = 0; i < data.Nights[j].Taxes.length; i++) {
                    data.Nights[j].Taxes[i].Balance = balance = (parseFloat(balance) + parseFloat(data.Nights[j].Taxes[i].TaxValue)).toFixed(2);
                }
                for (var i = 0; i < data.Nights[j].InvoiceItems.length; i++) {
                    if (data.Nights[j].InvoiceItems[i].ItemType == "otheritem")
                        data.Nights[j].InvoiceItems[i].Balance = balance = (parseFloat(balance) + parseFloat(data.Nights[j].InvoiceItems[i].ItemValue)).toFixed(2);
                }
                for (var i = 0; i < data.Nights[j].PaymentDetails.length; i++) {
                    data.Nights[j].PaymentDetails[i].Balance = balance = (parseFloat(balance) - parseFloat(data.Nights[j].PaymentDetails[i].PaymentValue)).toFixed(2);
                }
            }

            var divToPrint = $('#divToPrint');
            var printTemplate = '';
            divToPrint.html('');
            printTemplate = $('#invoiceDetailTemplate');

            if (data && divToPrint && divToPrint.length > 0
                && printTemplate && printTemplate.length > 0) {
                divToPrint.html(printTemplate.render(data));
                return divToPrint[0].innerHTML;
            }
            return "No data is available for printing";

        },
        CancelReservation: function () {
            args.id = window.GuestCheckinManager.BookingDto.BookingId ? window.GuestCheckinManager.BookingDto.BookingId : -1;;
            if(args.id>0)
            pmsService.CancelReservation(args);
        },

        UpdatePassword: function(args){
            pmsService.UpdatePassword(args);
        },

        AjaxHandlers: function () {
            // ajax handlers start
            pmsService.Handlers.OnAddBookingSuccess = function (data) {
                if (bookingStatus === "checkout") {
                    $('#btnSave').attr("disabled", true);
                    $('#btnCheckout').attr("disabled", true);
                    $('#btnCheckin').attr("disabled", true);
                    $('#saveInvoice').attr("disabled", true);
                    alert("Checkout is completed");
                    return;
                }

                var status = data.StatusDescription.toLowerCase();
                if (data.BookingId > 0 && data.GuestId > 0) {
                    window.GuestCheckinManager.BookingDto.BookingId = data.BookingId;
                    window.GuestCheckinManager.BookingDto.GuestId = data.GuestId;
                    window.GuestCheckinManager.BookingDto.RoomBookingId = data.RoomBookingId;
                    

                    if (bookingStatus === "reserved") {
                        $('#btnCancelReserved').show();
                        $('#btnSave').attr("disabled", true);
                    }
                    else {
                        $('#btnSave').attr("disabled", false);
                        $('#btnReserved').attr("disabled", true);
                    }
                    $('#btnCheckout').attr("disabled", false);
                    //$('#btnCheckin').attr("disabled", true);
                    $('#saveInvoice').attr("disabled", false);

                    var roomnumber = $("#roomddl option:selected").text();
                    var fname = $('#fName').val();
                    var lname = $('#lName').val();
                    var initials = $('#ddlInitials')[0].selectedOptions[0].innerText;
                    var message = 'Roomnumber ' + roomnumber + ' has been booked for ' + initials + ' ' + fname + ' ' + lname;
                    alert(message);
                    console.log(message);
                    // if booking is successful then upload image
                    uploadImage($("#uploadPhoto"));
                    // to load fresh data
                    window.GuestCheckinManager.AutoCollapseGuestHistory();

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
                window.GuestCheckinManager.PropertySettingResponseDto.RoomTypeSettings = null;
                window.GuestCheckinManager.PropertySettingResponseDto.RoomTypeSettings = data.RoomTypes;
                //storing room type data into session storage only for checkin screen exclude admin screen
                var divRoomTypeForCheckin = $('#divRoomTypeForCheckin');
                if (divRoomTypeForCheckin && divRoomTypeForCheckin.length > 0) {
                    pmsSession.SetItem("roomtypedata", JSON.stringify(data.RoomTypes));
                }
                var roomTypeDdl = $('#roomTypeDdl');
                if (roomTypeDdl && roomTypeDdl.length > 0) {
                    window.GuestCheckinManager.BindRoomTypeDdl(roomTypeDdl, window.GuestCheckinManager.PropertySettingResponseDto.RoomTypeSettings);
                }
                if (window.Notifications) window.Notifications.Notify("on-roomtype-get-success", null, null);
                if (window.Notifications) window.Notifications.Notify("on-populate-roomtypegrid", null, null);
            };

            pmsService.Handlers.OnGetRoomTypeByPropertyFailure = function () {
                // show error log
                console.error("Get Room type call failed");
            };

            pmsService.Handlers.OnGetRateTypeByPropertySuccess = function (data) {
                window.GuestCheckinManager.PropertySettingResponseDto.RateTypeSettings = null;
                window.GuestCheckinManager.PropertySettingResponseDto.RateTypeSettings = data.RateTypes;
                var divRateType = $('#divRateType');
                var rateTemplate = $('#rateTemplate');
                var rateTypeDdl = $('#rateTypeDdl');
                if (rateTypeDdl && rateTypeDdl.length > 0) {
                    window.GuestCheckinManager.BindRateTypeDdl(rateTypeDdl);
                } else if (divRateType && rateTemplate && divRateType.length > 0 && rateTemplate.length > 0) {
                    window.GuestCheckinManager.PopulateRateTypeGrid(data);
                }
            };

            pmsService.Handlers.OnGetRateTypeByPropertyFailure = function () {
                // show error log
                console.error("Get Room rate type call failed");
            };


            pmsService.Handlers.OnImageUploadSuccess = function (data) {
                console.log(data[0]);
            };

            pmsService.Handlers.OnImageUploadFailure = function () {
                // show error log
                console.error("Image upload failed");
            };

            pmsService.Handlers.OnGetRoomByDateSuccess = function (data) {
                if (!data || !data.Rooms || data.Rooms.length <= 0) return;

                //pmsSession.SetItem("roomdata", JSON.stringify(data.Rooms));
                var roomDdl = $('#roomddl');
                var roomTypeId = $('#roomTypeDdl').val();
                window.GuestCheckinManager.BindRoomDdl(roomDdl, roomTypeId, data.Rooms, true);
                //once booking detail is retrieve then clear bookingId from sessionstorage
                var sessionBookingId = pmsSession.GetItem("bookingId");
                if (sessionBookingId && !isNaN(parseInt(sessionBookingId)) && parseInt(sessionBookingId) > 0) {
                    pmsSession.RemoveItem("bookingId");
                    if (window.Notifications) window.Notifications.Notify("on-roombydate-get-success-dashboard-bookingid", null, null);
                }

                //once checkin detail is retrieve then clear roomid from sessionstorage
                var sessionRoomId = pmsSession.GetItem("roomid");
                if (sessionRoomId && !isNaN(parseInt(sessionRoomId)) && parseInt(sessionRoomId) > 0) {
                    //once value is set in input date then clear sessionstorage
                    pmsSession.RemoveItem("dtcheckin");
                    pmsSession.RemoveItem("dtcheckout");
                    pmsSession.RemoveItem("roomtypeid");
                    if (window.Notifications) window.Notifications.Notify("on-roombydate-get-success-dashboard-roomid", null, null);
                }
            };

            pmsService.Handlers.OnGetRoomByDateFailure = function () {
                // show error log
                console.error("get room call failed");
            };

            pmsService.Handlers.OnGetGuestHistoryByIdSuccess = function (data) {
                if (!data || !data.GuestHistory || data.GuestHistory.length <= 0) return;

                var guestId = window.GuestCheckinManager.BookingDto.GuestId ? window.GuestCheckinManager.BookingDto.GuestId : -1;
                if (guestId === -1) return;

                var idx = window.GuestCheckinManager.CheckIfKeyPresent(guestId, pmsSession.GuestSessionKey);
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
                window.GuestCheckinManager.BindCountryDdl(ddlCountryObj);
                //TODO: fill ddlIdCountry either via notification or on body onload
                if (ddlCountryObj[0].id === 'ddlCountry') {
                    window.GuestCheckinManager.BindCountryDdl($('#ddlIdCountry'));
                }
            };
            pmsService.Handlers.OnGetCountryFailure = function () {
                // show error log
                console.error("get country call failed");
            };

            pmsService.Handlers.OnGetStateByCountrySuccess = function (data) {
                if (!data || !data.States || data.States.length <= 0) return;
                pmsSession.SetItem("statedata", JSON.stringify(data.States));
            };

            pmsService.Handlers.OnGetStateByCountryFailure = function () {
                // show error log
                console.error("get state call failed");
            };

            pmsService.Handlers.OnGetAllGuestSuccess = function (data) {
                if (!data || !data.Guest || data.Guest.length <= 0) return;
                pmsSession.SetItem("guestinfo", JSON.stringify(data.Guest));
            };
            pmsService.Handlers.OnGetAllGuestFailure = function () {
                // show error log
                console.error("get guest call failed");
            };

            pmsService.Handlers.OnGetCityByStateSuccess = function (data) {
                if (!data || !data.City || data.City.length <= 0) return;
                pmsSession.SetItem("citydata", JSON.stringify(data.City));
            };
            pmsService.Handlers.OnGetCityByStateFailure = function () {
                // show error log
                console.error("get city call failed");
            };

            pmsService.Handlers.OnGetPaymentChargesSuccess = function (data) {
                if (!data || !data.Tax || data.Tax.length <= 0) return;
                $('#saveInvoice').attr("disabled", false);
                window.GuestCheckinManager.invoiceData = null;
                window.GuestCheckinManager.invoiceData = data;
                window.GuestCheckinManager.PopulateCharges(data);
            };
            pmsService.Handlers.OnGetPaymentChargesFailure = function () {
                // show error log
                console.error("get PaymentCharges call failed");
            };

            pmsService.Handlers.OnAddInvoiceSuccess = function (data) {
                var status = data.StatusDescription;
                if (data.ResponseObject > 0) {
                    window.GuestCheckinManager.BookingDto.InvoiceId = data.ResponseObject;
                    console.log(status);
                } else {
                    console.error(status);
                }
                alert(status);
            };

            pmsService.Handlers.OnAddInvoiceFailure = function () {
                // show error log
                console.error("Invoice is not added.");
            };

            pmsService.Handlers.OnGetInvoiceByIdSuccess = function (data) {
                if (!data || !data.Invoice || !data.Invoice.Tax || data.Invoice.Tax.length <= 0) return;
                $('#saveInvoice').attr("disabled", false);
                window.GuestCheckinManager.invoiceData = null;
                window.GuestCheckinManager.invoiceData = data;
                window.GuestCheckinManager.PopulateCharges(data);
            };
            pmsService.Handlers.OnGetInvoiceByIdFailure = function () {
                // show error log
                console.error("get invoice call failed");
            };

            pmsService.Handlers.OnGetBookingByIdSuccess = function (data) {
                if (!data || !data.Bookings || data.Bookings.length <= 0) return;
                window.GuestCheckinManager.PopulateUi(data.Bookings);
            };
            pmsService.Handlers.OnGetBookingByIdFailure = function () {
                // show error log
                console.error("get booking call failed");
            };

            pmsService.Handlers.OnGetAllPropertySuccess = function (data) {
                if (!data || !data.Properties || data.Properties.length <= 0) return;
                window.GuestCheckinManager.PropertySettingResponseDto.PropertySetting = null;
                window.GuestCheckinManager.PropertySettingResponseDto.PropertySetting = data.Properties;
                pmsSession.RemoveItem("allprops");
                pmsSession.SetItem("allprops", JSON.stringify(data.Properties));
                var divProperty = $('#divProperty');
                var propertyTemplate = $('#propertyTemplate');
                var ddlProperty = $('#ddlProperty');
                var panelProperty = $('#panelProperty');
                if (divProperty && propertyTemplate && divProperty.length > 0 && propertyTemplate.length > 0) {
                    $('#propmodal').removeClass('open');
                    window.GuestCheckinManager.PopulatePropertyGrid(data);
                } else if (ddlProperty && ddlProperty.length > 0) {
                    window.GuestCheckinManager.BindPropertyDdl(ddlProperty);
                }

                if (panelProperty) {
                    window.GuestCheckinManager.BindPropertyPanel($('#panelProperty .left ul'), data.Properties);
                }
                if (window.Notifications) window.Notifications.Notify("on-allproperty-get-success", null, null);
            };

            pmsService.Handlers.OnGetAllPropertyFailure = function () {
                // show error log
                console.error("get all property call failed");
            };

            pmsService.Handlers.OnGetPropertyForAccessSuccess = function (data) {
                if (!data || !data.Properties || data.Properties.length <= 0) return;
                window.GuestCheckinManager.PropertySettingResponseDto.PropertyForAccessSetting = null;
                window.GuestCheckinManager.PropertySettingResponseDto.PropertyForAccessSetting = data.Properties;

                var panelProperty = $('#panelProperty');
                if (panelProperty) {
                    window.GuestCheckinManager.BindPropertyPanel($('#panelProperty .left ul'), data.Properties);
                }
            };

            pmsService.Handlers.OnGetPropertyForAccessFailure = function () {
                // show error log
                console.error("get all property call failed");
            };

            pmsService.Handlers.OnAddPropertySuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                if (data.ResponseObject > 0) {
                    console.log(status);
                    //alert(status);
                    uploadImage($("#uploadPhoto"));
                    if (window.Notifications) window.Notifications.Notify("on-property-add-success", null, null);
                } else {
                    console.error(status);
                    alert(status);
                }
            };

            pmsService.Handlers.OnAddPropertyFailure = function () {
                // show error log
                console.error("Property is not added.");
            };

            pmsService.Handlers.OnDeleteBookingFailure = function () {
                // show error log
                console.error("Booking is not deleted.");
            };

            pmsService.Handlers.OnDeleteBookingSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnDeletePropertyFailure = function () {
                // show error log
                console.error("Property is not deleted.");
            };

            pmsService.Handlers.OnDeletePropertySuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnUpdatePropertyFailure = function () {
                // show error log
                console.error("Property is not updated.");
            };

            pmsService.Handlers.OnUpdatePropertySuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                uploadImage($("#uploadPhoto"));
                window.GuestCheckinManager.GetAllProperty();
                //alert(status);
            };

            pmsService.Handlers.OnAddRoomTypeSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                if (data.ResponseObject > 0) {
                    console.log(status);
                    //alert(status);
                    // to fetch new data                    
                    if (window.Notifications) window.Notifications.Notify("on-roomtype-add-success", null, null);
                } else {
                    console.error(status);
                    alert(status);
                }
            };

            pmsService.Handlers.OnAddRoomTypeFailure = function () {
                // show error log
                console.error("Roomtype is not added.");
            };

            pmsService.Handlers.OnAddFloorSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                if (data.ResponseObject > 0) {
                    console.log(status);
                    //alert(status);
                    // to fetch new data     
                    if (window.Notifications) window.Notifications.Notify("on-floor-add-success", null, null);
                } else {
                    console.error(status);
                    alert(status);
                }
            };

            pmsService.Handlers.OnAddFloorFailure = function () {
                // show error log
                console.error("Floor is not added.");
            };

            pmsService.Handlers.OnDeleteFloorFailure = function () {
                // show error log
                console.error("Floor is not deleted.");
            };

            pmsService.Handlers.OnDeleteFloorSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnUpdateFloorFailure = function () {
                // show error log
                console.error("Floor is not updated.");
            };

            pmsService.Handlers.OnUpdateFloorSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnDeleteRoomTypeFailure = function () {
                // show error log
                console.error("Roomtype is not deleted.");
            };

            pmsService.Handlers.OnDeleteRoomTypeSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnUpdateRoomTypeFailure = function () {
                // show error log
                console.error("Roomtype is not updated.");
            };

            pmsService.Handlers.OnUpdateRoomTypeSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnGetFloorsByPropertySuccess = function (data) {
                window.GuestCheckinManager.PropertySettingResponseDto.FloorSettings = null;
                window.GuestCheckinManager.PropertySettingResponseDto.FloorSettings = data.PropertyFloors;
                var divFloor = $('#divFloor');
                var floorTemplate = $('#floorTemplate');
                if (divFloor && floorTemplate && divFloor.length > 0 && floorTemplate.length > 0) {
                    window.GuestCheckinManager.PopulateFloorGrid(data);
                } else {
                    if (window.Notifications) window.Notifications.Notify("on-floor-get-success", null, null);
                }
            };

            pmsService.Handlers.OnGetFloorsByPropertyFailure = function () {
                // show error log
                console.error("Get Floor call failed");
            };

            pmsService.Handlers.OnGetPaymentTypeByPropertySuccess = function (data) {
                window.GuestCheckinManager.PropertySettingResponseDto.PaymentTypeSettings = null;
                window.GuestCheckinManager.PropertySettingResponseDto.PaymentTypeSettings = data.PaymentTypes;
                window.GuestCheckinManager.PopulatePaymentTypeGrid(data);

                var divInvoice = $('#divInvoice');
                var invoiceTemplate = $('#invoiceTemplate');

                if (divInvoice && divInvoice.length > 0 && invoiceTemplate && invoiceTemplate.length > 0) {
                    //storing payment type data into session storage only for checkin screen exclude paymenttype admin screen
                    pmsSession.SetItem("paymenttype", JSON.stringify(data.PaymentTypes));
                    if (window.Notifications) window.Notifications.Notify("on-paymenttype-get-success", null, null);
                }
                var divBooking = $('#divBooking');
                var divExpense = $('#divExpense');
                if ((divBooking && divBooking.length > 0) || (divExpense && divExpense.length > 0)) {
                    if (window.Notifications) window.Notifications.Notify("on-paymenttype-get-success-booking", null, null);
                }
            };

            pmsService.Handlers.OnGetPaymentTypeByPropertyFailure = function () {
                // show error log
                console.error("Get Payment type call failed");
            };

            pmsService.Handlers.OnAddPaymentTypeSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                if (data.ResponseObject > 0) {
                    console.log(status);
                    //alert(status);
                    // to fetch new data                    
                    if (window.Notifications) window.Notifications.Notify("on-paymenttype-add-success", null, null);

                } else {
                    console.error(status);
                    alert(status);
                }
            };

            pmsService.Handlers.OnAddPaymentTypeFailure = function () {
                // show error log
                console.error("Payment type is not added.");
            };

            pmsService.Handlers.OnDeletePaymentTypeFailure = function () {
                // show error log
                console.error("Payment type is not deleted.");
            };

            pmsService.Handlers.OnDeletePaymentTypeSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnUpdatePaymentTypeFailure = function () {
                // show error log
                console.error("Payment type is not updated.");
            };

            pmsService.Handlers.OnUpdatePaymentTypeSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnGetExtraChargeByPropertySuccess = function (data) {
                window.GuestCheckinManager.PropertySettingResponseDto.ExtraChargeSettings = null;
                window.GuestCheckinManager.PropertySettingResponseDto.ExtraChargeSettings = data.ExtraCharges;
                //storing extra charge data into session storage
                pmsSession.SetItem("extracharges", JSON.stringify(data.ExtraCharges));
                window.GuestCheckinManager.PopulateExtraChargeGrid(data);
                if (window.Notifications) window.Notifications.Notify("on-extracharge-get-success", null, null);
            };

            pmsService.Handlers.OnGetExtraChargeByPropertyFailure = function () {
                // show error log
                console.error("Get Extra charge call failed");
            };

            pmsService.Handlers.OnAddExtraChargeSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                if (data.ResponseObject > 0) {
                    console.log(status);
                    //alert(status);
                    // to fetch new data
                    if (window.Notifications) window.Notifications.Notify("on-extracharge-add-success", null, null);
                } else {
                    console.error(status);
                    alert(status);
                }
            };

            pmsService.Handlers.OnAddExtraChargeFailure = function () {
                // show error log
                console.error("Extra Charge is not added.");
            };

            pmsService.Handlers.OnDeleteExtraChargeFailure = function () {
                // show error log
                console.error("Extra Charge is not deleted.");
            };

            pmsService.Handlers.OnDeleteExtraChargeSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnUpdateExtraChargeFailure = function () {
                // show error log
                console.error("Extra Charge is not updated.");
            };

            pmsService.Handlers.OnUpdateExtraChargeSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnGetTaxByPropertySuccess = function (data) {
                window.GuestCheckinManager.PropertySettingResponseDto.TaxSettings = null;
                window.GuestCheckinManager.PropertySettingResponseDto.TaxSettings = data.Taxes;
                window.GuestCheckinManager.PopulateTaxGrid(data);
            };

            pmsService.Handlers.OnGetTaxByPropertyFailure = function () {
                // show error log
                console.error("Get tax call failed");
            };

            pmsService.Handlers.OnAddTaxSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                if (data.ResponseObject > 0) {
                    console.log(status);
                    //alert(status);
                    // to fetch new data
                    if (window.Notifications) window.Notifications.Notify("on-tax-add-success", null, null);
                } else {
                    console.error(status);
                    alert(status);
                }
            };

            pmsService.Handlers.OnAddTaxFailure = function () {
                // show error log
                console.error("Tax is not added.");
            };

            pmsService.Handlers.OnDeleteTaxFailure = function () {
                // show error log
                console.error("Tax is not deleted.");
            };

            pmsService.Handlers.OnDeleteTaxSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnUpdateTaxFailure = function () {
                // show error log
                console.error("Tax is not updated.");
            };

            pmsService.Handlers.OnUpdateTaxSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            //Room Callbacks

            pmsService.Handlers.OnGetRoomByPropertySuccess = function (data) {
                window.GuestCheckinManager.PropertySettingResponseDto.RoomSettings = null;
                window.GuestCheckinManager.PropertySettingResponseDto.RoomSettings = data.Rooms;
                if (window.Notifications) window.Notifications.Notify("on-room-get-success", null, null);
                window.GuestCheckinManager.PopulateRoomGrid(data);
            };

            pmsService.Handlers.OnGetRoomByPropertyFailure = function () {
                // show error log
                console.error("Get room call failed");
            };

            pmsService.Handlers.OnAddRateTypeSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                if (data.ResponseObject > 0) {
                    console.log(status);
                    // to fetch new data                    
                    //alert(status);
                    if (window.Notifications) window.Notifications.Notify("on-ratetype-add-success", null, null);
                } else {
                    console.error(status);
                    alert(status);
                }
            };

            pmsService.Handlers.OnAddRateTypeFailure = function () {
                // show error log
                console.error("Rate type is not added.");
            };

            pmsService.Handlers.OnDeleteRateTypeFailure = function () {
                // show error log
                console.error("Rate type is not deleted.");
            };

            pmsService.Handlers.OnDeleteRateTypeSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnUpdateRateTypeFailure = function () {
                // show error log
                console.error("Rate type is not updated.");
            };

            pmsService.Handlers.OnUpdateRateTypeSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
                if (window.Notifications) window.Notifications.Notify("on-ratetype-update-success", null, null);
            };

            pmsService.Handlers.OnGetRoomRateByPropertySuccess = function (data) {
                window.GuestCheckinManager.PropertySettingResponseDto.RateSettings = null;
                window.GuestCheckinManager.PropertySettingResponseDto.RateSettings = data.RoomRate;

                //storing room rate data into session storage only for checkin screen exclude admin screen
                var divRateTypeForCheckin = $('#divRateTypeForCheckin');
                if (divRateTypeForCheckin && divRateTypeForCheckin.length > 0) {
                    pmsSession.SetItem("roomratedata", JSON.stringify(data.RoomRate));
                }

                window.GuestCheckinManager.PopulateRateTab(data);
                // to show default 1st tab data hence pass index 0
                window.GuestCheckinManager.PopulateRoomRateInGrid(data.RoomRate[0]);
                if (window.Notifications) window.Notifications.Notify("on-roomrate-get-success", null, null);
            };

            pmsService.Handlers.OnGetRoomRateByPropertyFailure = function () {
                // show error log
                console.error("Get room rate call failed");
            };

            pmsService.Handlers.OnAddRoomRateSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                if (status.indexOf('successfully') >= 0) {
                    console.log(status);
                    // to fetch new data                    
                    //alert(status);
                    if (window.Notifications) window.Notifications.Notify("on-roomrate-add-success", null, null);
                } else {
                    console.error(status);
                    alert(status);
                }
            };

            pmsService.Handlers.OnAddRoomRateFailure = function () {
                // show error log
                console.error("Room rate is not added.");
            };

            pmsService.Handlers.OnDeleteRoomRateFailure = function () {
                // show error log
                console.error("Room rate is not deleted.");
            };

            pmsService.Handlers.OnDeleteRoomRateSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnUpdateRoomRateFailure = function () {
                // show error log
                console.error("Room rate is not updated.");
            };

            pmsService.Handlers.OnUpdateRoomRateSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
                if (window.Notifications) window.Notifications.Notify("on-roomrate-update-success", null, null);
            };

            pmsService.Handlers.OnAddRoomSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                if (status.indexOf('successfully') >= 0) {
                    console.log(status);
                    // to fetch new data                    
                    //alert(status);
                    if (window.Notifications) window.Notifications.Notify("on-room-add-success", null, null);
                } else {
                    console.error(status);
                    alert(status);
                }
            };

            pmsService.Handlers.OnAddRoomFailure = function () {
                // show error log
                console.error("Room is not added.");
            };

            pmsService.Handlers.OnDeleteRoomFailure = function () {
                // show error log
                console.error("Room is not deleted.");
            };

            pmsService.Handlers.OnDeleteRoomSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnUpdateRoomFailure = function () {
                // show error log
                console.error("Room is not updated.");
            };

            pmsService.Handlers.OnUpdateRoomSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
                if (window.Notifications) window.Notifications.Notify("on-room-update-success", null, null);
            };

            pmsService.Handlers.OnUpdateRoomStatusFailure = function () {
                // show error log
                console.error("Room status is not updated.");
            };

            pmsService.Handlers.OnUpdateRoomStatusSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                if (window.Notifications) window.Notifications.Notify("on-roomstatus-update-success", null, null);
                //alert(status);
            };

            pmsService.Handlers.OnUpdateStatusFailure = function () {
                // show error log
                console.error("Booking status is not updated.");
            };

            pmsService.Handlers.OnUpdateStatusSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                if (window.Notifications) window.Notifications.Notify("on-booking-status-success", null, null);
                //alert(status);
            };

            pmsService.Handlers.OnGetBookingTransactionFailure = function () {
                // show error log
                console.error("Get booking transaction failed.");
            };

            pmsService.Handlers.OnGetBookingTransactionSuccess = function (data) {
                if (!data) return;
                window.GuestCheckinManager.PropertySettingResponseDto.Bookings = null;
                window.GuestCheckinManager.PropertySettingResponseDto.Bookings = data.Bookings;

                var divBooking = $('#divBooking');
                var bookingTemplate = $('#bookingTemplate');
                if (divBooking && bookingTemplate && divBooking.length > 0 && bookingTemplate.length > 0) {
                    window.GuestCheckinManager.PopulateBookingGrid(data);
                }
                //if (window.Notifications) window.Notifications.Notify("on-allproperty-get-success", null, null);
            };

            // ajax handlers end

            pmsService.Handlers.OnGetExpenseCategoryByPropertySuccess = function (data) {
                window.GuestCheckinManager.PropertySettingResponseDto.ExpenseCategorySettings = null;
                window.GuestCheckinManager.PropertySettingResponseDto.ExpenseCategorySettings = data.ExpenseCategories;
                window.GuestCheckinManager.PopulateExpenseCategoryGrid(data);

                if (window.Notifications) window.Notifications.Notify("on-expensecategory-get-success", null, null);
            };

            pmsService.Handlers.OnGetExpenseCategoryByPropertyFailure = function () {
                console.error("Get Expense Category call failed");
            };

            pmsService.Handlers.OnAddExpenseCategorySuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                if (data.ResponseObject > 0) {
                    console.log(status);
                    //alert(status);
                    // to fetch new data                    
                    if (window.Notifications) window.Notifications.Notify("on-expensecategory-add-success", null, null);

                } else {
                    console.error(status);
                    alert(status);
                }
            };

            pmsService.Handlers.OnAddExpenseCategoryFailure = function () {
                // show error log
                console.error("Expense Category is not added.");
            };

            pmsService.Handlers.OnDeleteExpenseCategoryFailure = function () {
                // show error log
                console.error("Expense Category is not deleted.");
            };

            pmsService.Handlers.OnDeleteExpenseCategorySuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnUpdateExpenseCategoryFailure = function () {
                // show error log
                console.error("Expense Category is not updated.");
            };

            pmsService.Handlers.OnUpdateExpenseCategorySuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnGetExpenseBySearchSuccess = function (data) {
                window.GuestCheckinManager.PropertySettingResponseDto.ExpenseSettings = null;
                window.GuestCheckinManager.PropertySettingResponseDto.ExpenseSettings = data.Expenses;
                window.GuestCheckinManager.PopulateExpenseGrid(data);
               
            };

            pmsService.Handlers.OnGetExpenseBySearchFailure = function () {
                console.error("Get Expense call failed");
            };

            pmsService.Handlers.OnAddExpenseSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                if (data.ResponseObject > 0) {
                    console.log(status);
                    //alert(status);
                    // to fetch new data                    
                    if (window.Notifications) window.Notifications.Notify("on-expense-add-success", null, null);

                } else {
                    console.error(status);
                    alert(status);
                }
            };

            pmsService.Handlers.OnAddExpenseFailure = function () {
                // show error log
                console.error("Expense is not added.");
            };

            pmsService.Handlers.OnDeleteExpenseFailure = function () {
                // show error log
                console.error("Expense s not deleted.");
            };

            pmsService.Handlers.OnDeleteExpenseSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnUpdateExpenseFailure = function () {
                // show error log
                console.error("Expense is not updated.");
            };

            pmsService.Handlers.OnUpdateExpenseSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                if (window.Notifications) window.Notifications.Notify("on-expense-add-success", null, null);
                //alert(status);
            };


            pmsService.Handlers.OnGetShiftReportFailure = function () {
                // show error log
                console.error("Get Shift Report failure");
            };

            pmsService.Handlers.OnGetShiftReportSuccess = function (data) {
                window.GuestCheckinManager.ReportDto.Shifts = null;
                window.GuestCheckinManager.ReportDto.Shifts = data.ShiftRecords;
                window.GuestCheckinManager.PopulateShiftReportGrid(data);
            };

            pmsService.Handlers.OnGetConsolidatedShiftReportFailure = function () {
                // show error log
                console.error("Get Consolidated Shift Report failure");
            };

            pmsService.Handlers.OnGetConsolidatedShiftReportSuccess = function (data) {
                window.GuestCheckinManager.ReportDto.ConsolidatedShifts = null;
                window.GuestCheckinManager.ReportDto.ConsolidatedShifts = data.ConsolidatedShiftRecords;
                window.GuestCheckinManager.PopulateConsolidatedShiftReportGrid(data);
            };

            pmsService.Handlers.OnGetManagerDataFailure = function () {
                // show error log
                console.error("Get Manager Report failure");
            };

            pmsService.Handlers.OnGetManagerDataSuccess = function (data) {
                window.GuestCheckinManager.ReportDto.ManagerRecords = null;
                window.GuestCheckinManager.ReportDto.ManagerRecords = data.ManagerRecords;
                window.GuestCheckinManager.PopulateManagerReportGrid(data);
            };


            pmsService.Handlers.OnAddUserSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                if (data.ResponseObject > 0) {
                    console.log(status);
                    if (window.Notifications) window.Notifications.Notify("on-user-add-success", null, data.ResponseObject);
                } else {
                    console.error(status);
                    alert(status);
                }
            };

            pmsService.Handlers.OnAddUserFailure = function () {
                // show error log
                console.error("User is not added.");
            };

            pmsService.Handlers.OnDeleteUserFailure = function () {
                // show error log
                console.error("User s not deleted.");
            };

            pmsService.Handlers.OnDeleteUserSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnUpdateUserFailure = function () {
                // show error log
                console.error("User is not updated.");
            };

            pmsService.Handlers.OnUpdateUserSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                if (window.Notifications) window.Notifications.Notify("on-user-add-success", null, null);
                //alert(status);
            };

            pmsService.Handlers.OnGetAllUserSuccess = function (data) {
                if (!data || !data.Users || data.Users.length <= 0) return;
                window.GuestCheckinManager.PropertySettingResponseDto.UserSetting = null;
                window.GuestCheckinManager.PropertySettingResponseDto.UserSetting = data.Users;

                var divUser = $('#divUser');
                var userTemplate = $('#userTemplate');
                if (divUser && userTemplate && divUser.length > 0 && userTemplate.length > 0) {
                    $('#propmodal').removeClass('open');
                    window.GuestCheckinManager.PopulateUserGrid(data);
                }
                if (window.Notifications) window.Notifications.Notify("on-allUser-get-success", null, null);
            };

            pmsService.Handlers.OnGetAllUserFailure = function () {
                // show error log
                console.error("get all User call failed");
            };

            pmsService.Handlers.OnGetPropertyByUserIdSuccess = function (data) {
                if (!data || !data.Properties || data.Properties.length <= 0) {
                    $('#panelProperty .right ul').empty();
                    return;
                }

                var panelProperty = $('#panelProperty');
                if (panelProperty) {
                    window.GuestCheckinManager.BindPropertyPanel($('#panelProperty .right ul'), data.Properties);
                    window.GuestCheckinManager.RemovePropertyPanel($('#panelProperty .left ul'), data.Properties);
                }
            };

            pmsService.Handlers.OnGetPropertyByUserIdFailure = function () {
                // show error log
                console.error("get all property call failed");
            };

            pmsService.Handlers.OnGetAllFunctionalitySuccess = function (data) {
                if (!data || !data.Functionalities || data.Functionalities.length <= 0) return;

                window.GuestCheckinManager.PropertySettingResponseDto.AllFunctionalitiesSettings = null;
                window.GuestCheckinManager.PropertySettingResponseDto.AllFunctionalitiesSettings = data.Functionalities;
                if (window.Notifications) window.Notifications.Notify("on-functionality-get-success", null, null);
            };

            pmsService.Handlers.OnGetAllFunctionalityFailure = function () {
                // show error log
                console.error("get all functionalities call failed");
            };

            pmsService.Handlers.OnGetFunctionalityByUserIdSuccess = function (data) {
                if (!data || !data.Functionalities || data.Functionalities.length <= 0) {
                    $('#panelFunctionality .right ul').empty();
                    return;
                }
                window.GuestCheckinManager.PropertySettingResponseDto.FunctionalitiesSettings = null;
                window.GuestCheckinManager.PropertySettingResponseDto.FunctionalitiesSettings = data.Functionalities;
                var panelFunctionality = $('#panelFunctionality');
                if (panelFunctionality) {
                    window.GuestCheckinManager.BindFunctionalityPanel($('#panelFunctionality .right ul'), data.Functionalities);
                    window.GuestCheckinManager.RemoveFunctionalityPanel($('#panelFunctionality .left ul'), data.Functionalities);
                }
                if (window.Notifications) window.Notifications.Notify("on-functionality-user-get-success", null, null);
            };

            pmsService.Handlers.OnGetFunctionalityByUserIdFailure = function () {
                // show error log
                console.error("get all functionalities by userid call failed");
            };


            pmsService.Handlers.OnInsertUserAccessSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
            };

            pmsService.Handlers.OnInsertUserAccessFailure = function () {
                // show error log
                console.error("get all functionalities by userid call failed");
            };

            pmsService.Handlers.OnGetConsolidatedManagerDataPreviousMonthFailure = function () {
                // show error log
                console.error("Get Consolidated Manager Report failure");
            };

            pmsService.Handlers.OnGetConsolidatedManagerDataPreviousMonthSuccess = function (data) {
                window.GuestCheckinManager.ReportDto.ConsolidatedManagerRecordsMonth = null;
                window.GuestCheckinManager.ReportDto.ConsolidatedManagerRecordsMonth = data.ConsolidatedManagerRecords;
                window.GuestCheckinManager.PopulateConsolidatedManagerReportGridMonth(data);
            };

            pmsService.Handlers.OnGetConsolidatedManagerDataPreviousYearFailure = function () {
                // show error log
                console.error("Get Consolidated Manager Report failure");
            };

            pmsService.Handlers.OnGetConsolidatedManagerDataPreviousYearSuccess = function (data) {
                window.GuestCheckinManager.ReportDto.ConsolidatedManagerRecordsYear = null;
                window.GuestCheckinManager.ReportDto.ConsolidatedManagerRecordsYear = data.ConsolidatedManagerRecords;
                window.GuestCheckinManager.PopulateConsolidatedManagerReportGridYear(data);
            };

            pmsService.Handlers.OnGetGuestSummaryFailure = function (data) {
                console.error("Get Guest Summary Report failure");
            };

            pmsService.Handlers.OnGetGuestSummarySuccess = function (data) {
                window.GuestCheckinManager.ReportDto.GuestSummary = null;
                window.GuestCheckinManager.ReportDto.GuestSummary = data.GuestSummary;
                window.GuestCheckinManager.PopulateGuestSummaryGrid(data);
            };


            pmsService.Handlers.OnAddGuestSuccess = function (data) {
                // if booking is successful then upload image
                uploadImage($("#uploadPhoto"));

                var status = data.StatusDescription.toLowerCase();
                if (data.ResponseObject > 0) {
                    console.log(status);
                    if (window.Notifications) window.Notifications.Notify("on-guest-add-success", null, data.ResponseObject);
                } else {
                    console.error(status);
                    alert(status);
                }
            };

            pmsService.Handlers.OnAddGuestFailure = function () {
                // show error log
                console.error("Guest is not added.");
            };

            pmsService.Handlers.OnDeleteGuestFailure = function () {
                // show error log
                console.error("Guest s not deleted.");
            };

            pmsService.Handlers.OnDeleteGuestSuccess = function (data) {
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                //alert(status);
            };

            pmsService.Handlers.OnUpdateGuestFailure = function () {
                // show error log
                console.error("Guest is not updated.");
            };

            pmsService.Handlers.OnUpdateGuestSuccess = function (data) {
                uploadImage($("#uploadPhoto"));
                var status = data.StatusDescription.toLowerCase();
                console.log(status);
                if (window.Notifications) window.Notifications.Notify("on-guest-add-success", null, null);
                //alert(status);
            };

            pmsService.Handlers.OnGetGuestSuccess = function (data) {
                if (!data || !data.Guest || data.Guest.length <= 0) return;
                window.GuestCheckinManager.PropertySettingResponseDto.GuestSetting = null;
                window.GuestCheckinManager.PropertySettingResponseDto.GuestSetting = data.Guest;

                var divGuest = $('#divGuest');
                var guestTemplate = $('#guestTemplate');
                if (divGuest && guestTemplate && divGuest.length > 0 && guestTemplate.length > 0) {
                    $('#propmodal').removeClass('open');
                    window.GuestCheckinManager.PopulateGuestGrid(data);
                }
                if (window.Notifications) window.Notifications.Notify("on-allGuest-get-success", null, null);
            };

            pmsService.Handlers.OnGetGuestFailure = function () {
                // show error log
                console.error("get all Guest call failed");
            };

            pmsService.Handlers.OnCancelReservationFailure = function () {
                // show error log
                console.error("Reservation can not Cancelled.");
            };

            pmsService.Handlers.OnCancelReservationSuccess = function (data) {
                if (data.IsCancelled) {
                    alert("Selected Reservation is Cancelled.");
                    window.location.reload();
                }
            };

            pmsService.Handlers.OnUpdatePasswordFailure = function () {
                // show error log
                console.error("Password is not updated.");
                alert('Something went wrong contact to administrator.');
            };

            pmsService.Handlers.OnUpdatePasswordSuccess = function (data) {
                // success
                if (data.ResponseStatus == "Failure")
                    alert('Something went wrong. Please try again.');
                else {
                    alert('Password change successfully.');
                    cancel();
                }
            };
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

    function preparePropertyData(data) {
        var propertyData = $.parseJSON(window.PmsSession.GetItem("allprops"));
        if (!propertyData || propertyData.length <= 0) return data;
        var selectedProperty = $('#ddlGlobalProperty').val();
        if (selectedProperty === "-1") return data;
        var idx = window.GuestCheckinManager.CheckIfKeyPresent(parseInt(selectedProperty), propertyData);
        if (idx < 0) return data;
        var selectedPropertyInfo = propertyData[idx];
        data.PropertyName = selectedPropertyInfo.PropertyName;
        data.PropertyPhone = selectedPropertyInfo.Phone;
        data.PropertyCode = selectedPropertyInfo.PropertyCode;
        data.PropertyCity = selectedPropertyInfo.City.Name;
        data.PropertyCountry = selectedPropertyInfo.Country.Name;
        data.PropertyState = selectedPropertyInfo.State.Name;
        data.SecondaryName = selectedPropertyInfo.SecondaryName;
        data.PropertyZip = selectedPropertyInfo.Zipcode;
        data.PropertyAddress = selectedPropertyInfo.FullAddress;
        data.Website = selectedPropertyInfo.WebSiteAddress;
        data.Fax = selectedPropertyInfo.Fax;
        return data;
    }

    function prepareLoadInvoiceRequestDto() {
        var getInvoiceRequestDto = {};

        var dateFrom = $('#dateFrom').val();
        var dateTo = $('#dateTo').val();
        var roomType = $('#roomTypeDdl').val();
        var roomId = $('#roomddl').val();
        var rateTypeId = $('#rateTypeDdl').val();
        var noOfHours = 0;
        var noOfDays = 1;
        if (!dateFrom || !dateTo) {
            noOfDays = 1;
        } else {
            var daysDiff = window.GuestCheckinManager.GetDays(dateFrom, dateTo);
            noOfDays = daysDiff <= 0 ? 1 : daysDiff;
        }

        noOfHours = window.GuestCheckinManager.GetSelectedCheckoutHrs();
        getInvoiceRequestDto.PropertyId = getPropertyId();
        getInvoiceRequestDto.RoomTypeId = roomType;
        getInvoiceRequestDto.RoomId = roomId;
        getInvoiceRequestDto.IsHourly = $('#hourCheckin')[0].checked ? true : false;
        getInvoiceRequestDto.NoOfHours = $('#hourCheckin')[0].checked && parseInt(noOfHours) > 0 ? parseInt(noOfHours) : 0;
        getInvoiceRequestDto.NoOfDays = noOfDays;
        getInvoiceRequestDto.RateTypeId = rateTypeId;

        return getInvoiceRequestDto;
    }

    function validateLoadInvoiceCall() {
        var dateFrom = $('#dateFrom').val();
        var dateTo = $('#dateTo').val();
        var roomType = $('#roomTypeDdl').val();
        var rateType = $('#rateTypeDdl').val();
        var roomId = $('#roomddl').val();
        var noOfHours = $('#hoursComboBox').val();

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

        if (!roomId || roomId === '-1') {
            alert("Select proper room");
            return false;
        }

        if ($('#hourCheckin')[0].checked && noOfHours === '-1') {
            alert("Please select proper checkout hours");
            return false;
        }
        return true;
    }

    function sortHourlyDdl(ddlHourlyOptions, ddlHourly) {
        var arr = ddlHourlyOptions.map(function (_, o) {
            return {
                t: $(o).text(),
                v: o.value
            };
        }).get();

        arr.sort(function (o1, o2) {
            return o1.t > o2.t ? 1 : o1.t < o2.t ? -1 : 0;
        });

        ddlHourly.empty();
        ddlHourly.append(new Option("Select Hrs", "-1"));
        for (var i = 0; i < arr.length; i++) {
            if (arr[i].v === "-1") continue;
            ddlHourly.append(new Option(arr[i].t + "-hr", arr[i].v));
        }
    }

    function filterCityByStateId(stateId, data) {
        var filterData = [];
        for (var i = 0; i < data.length; i++) {
            // lookup for stateId
            if (!data[i] || !data[i].StateId || data[i].StateId <= 0 || data[i].StateId !== parseInt(stateId)) continue;
            filterData.push(data[i]);
        }
        return filterData;
    }

    function filterStateByCountryId(countryId, data) {
        var filterData = [];
        for (var i = 0; i < data.length; i++) {
            // lookup for countryId
            if (!data[i] || !data[i].CountryId || data[i].CountryId <= 0 || data[i].CountryId !== parseInt(countryId)) continue;
            filterData.push(data[i]);
        }
        return filterData;
    }

    function populateAddress(address) {
        $('#address').val(address.Address1);
        $('#zipCode').val(address.ZipCode);
        //$('#ddlCountry').empty();
        //$('#ddlState').empty();
        //$('#ddlCity').empty();
        //$('#ddlCountry').append(new Option(address.Country, address.Country));
        //$('#ddlState').append(new Option(address.State, address.State));
        //$('#ddlCity').append(new Option(address.City, address.City));
        $("#ddlCountry option:contains(" + address.Country + ")").attr('selected', 'selected');
        window.GuestCheckinManager.BindStateDdl($("#ddlCountry").val(), $('#ddlState'));
        $("#ddlState option:contains(" + address.State + ")").attr('selected', 'selected');
        window.GuestCheckinManager.BindCityDdl($("#ddlState").val(), $('#ddlCity'));
        $("#ddlCity option:contains(" + address.City + ")").attr('selected', 'selected');
    }

    function populateAdditionalGuest(additionalguest) {
        $('#adFName').val(additionalguest.FirstName);
        $('#adLName').val(additionalguest.LastName);
    }

    function populateGuestMapping(guestmapping) {
        $("#ddlIdType").val(guestmapping.IDTYPEID);
        $("#idDetails").val(guestmapping.IDDETAILS);
        $("#idExpiry").val(formatAMPM(guestmapping.IdExpiryDate.replace('T', ' ')));
        //$('#ddlIdCountry').empty();
        //$('#ddlIdState').empty();
        //$('#ddlIdCountry').append(new Option(guestmapping.IdIssueCountry, guestmapping.IdIssueCountry));
        //$('#ddlIdState').append(new Option(guestmapping.IdIssueState, guestmapping.IdIssueState));
        $("#ddlIdCountry option:contains(" + guestmapping.IdIssueCountry + ")").attr('selected', 'selected');
        window.GuestCheckinManager.BindStateDdl($("#ddlIdCountry").val(), $('#ddlIdState'));
        $("#ddlIdState option:contains(" + guestmapping.IdIssueState + ")").attr('selected', 'selected');
    }

    function extractFileNameFromFilePath(fPath) {
        var fName = "";
        if (fPath.indexOf(':') < 0) return fName;
        var idx = fPath.lastIndexOf('\\');
        var len = fPath.length;
        fName = fPath.substr(idx + 1, len - 1);
        return fName;
    }

    function populateRoomDetails(data) {
        //$('#roomTypeDdl').empty();
        //$('#roomddl').empty();
        //$('#rateTypeDdl').empty();
        //$('#hoursComboBox').empty();
        $('#hourCheckin')[0].checked = data[0].ISHOURLYCHECKIN;
        if (data[0].ISHOURLYCHECKIN) {
            window.GuestCheckinManager.FillHourlyDdl($('#hoursComboBox'));
            $("#hoursComboBox option:contains(" + data[0].HOURSTOSTAY + "-hr" + ")").attr('selected', 'selected');
            var selectedHr = $("#hoursComboBox option:selected").text();
            // filter only hourly rate type  
            window.GuestCheckinManager.FilterRateType($('#rateTypeDdl'), selectedHr);
        }
        $('#hoursComboBox').prop("disabled", !$('#hourCheckin')[0].checked);
        if (data[0].CheckinTime) {
            $('#dateFrom').val(formatAMPM(data[0].CheckinTime.replace('T', ' ')));
        }

        if (data[0].CheckoutTime) {
            $('#dateTo').val(formatAMPM(data[0].CheckoutTime.replace('T', ' ')));
        }

        data[0].NoOfAdult > 0 ? $("#ddlAdults").val(data[0].NoOfAdult) : $("#ddlAdults").val(0);
        data[0].NoOfChild > 0 ? $("#ddlChild").val(data[0].NoOfChild) : $("#ddlChild").val(0);
        $('#transRemarks').val(data[0].TransactionRemarks);
        $('#guestComments').val(data[0].GuestRemarks);
        //$('#rateTypeDdl').append(new Option(data[0].RateType.Name, data[0].RateType.Id));
        //$('#roomTypeDdl').append(new Option(data[0].RoomBookings[0].Room.RoomType.Name, data[0].RoomBookings[0].Room.RoomType.Id));                

        $('#roomTypeDdl').val(data[0].RoomBookings[0].Room.RoomType.Id);
        // use this room number if calendar change event is fired
        roomSelectedFromDashBoard = parseInt(data[0].RoomBookings[0].Room.Id);
        Notifications.SubscribeActive("on-sel-room-dashboard", function (sender, args) {
            $('#roomddl').val(roomSelectedFromDashBoard);
        });
        // since room data is not available so we have subscribe the event
        Notifications.SubscribeActive("on-roombydate-get-success-dashboard-bookingid", function (sender, args) {
            $('#roomddl').append(new Option(data[0].RoomBookings[0].Room.Number, data[0].RoomBookings[0].Room.Id));
            $('#roomddl').val(data[0].RoomBookings[0].Room.Id);
            $('#rateTypeDdl').val(data[0].RateType.Id);
            // when all the pre-requisite ddl data is populated call load invoice
            window.GuestCheckinManager.LoadInvoice();
        });
        if (window.GuestCheckinManager.ShouldCallGetRoomApi()) {
            window.GuestCheckinManager.GetRoomByDate($('#dateFrom').val(), $('#dateTo').val());
        }
    }

    function getDate(date) {
        var result = new Date(date);
        result.setMinutes(result.getMinutes() - result.getTimezoneOffset());
        return result;
    }

    function getPropertyId() {
        window.GuestCheckinManager.BookingDto.PropertyId = pmsSession.GetItem("propertyid");
        return window.GuestCheckinManager.BookingDto.PropertyId;
    }

    function applyDiscount(totalCharge, isElementDiscountAmt) {
        if (!totalCharge || isNaN(totalCharge)) return 0;
        var discountPercent = $('#discountPercent').val().replace('%', '');
        discountPercent = !discountPercent || isNaN(discountPercent) ? 0 : parseFloat(discountPercent, 10).toFixed(2);
        var disAmtFromPercent = (parseFloat(discountPercent) * parseFloat(totalCharge)) / 100;
        var directDiscountAmt = $('#discountAmt').val();
        // if no direct discount amount is provided
        if (!isElementDiscountAmt) {
            $('#discountAmt').val(disAmtFromPercent.toFixed(2));
        }
        if (isElementDiscountAmt && disAmtFromPercent > 0 && (parseFloat(directDiscountAmt) === 0 || directDiscountAmt.trim() === '')) {
            $('#discountAmt').val(disAmtFromPercent.toFixed(2));
        }
        var discountedAmount = $('#discountAmt').val().trim() === '' || isNaN($('#discountAmt').val()) || parseFloat($('#discountAmt').val()) <= 0 ? 0 : parseFloat($('#discountAmt').val());
        totalCharge = (parseFloat(totalCharge) - discountedAmount).toFixed(2);
        return totalCharge;
    }

    function appendTotalRoomCharge(data) {
        if (!data) return data;
        var tax = {};
        tax.TaxName = 'Total Room Charge';
        tax.IsDefaultCharges = true;
        data.Tax.push(tax);
        return data;
    }

    function prepareAddress() {
        var addresses = [];
        var address = {};

        address.Id = window.GuestCheckinManager.BookingDto.AddressId ? window.GuestCheckinManager.BookingDto.AddressId : -1;
        address.City = $("#ddlCity option:selected").text();
        address.State = $("#ddlState option:selected").text();
        address.Country = $("#ddlCountry option:selected").text();
        address.ZipCode = $('#zipCode').val();
        address.Address1 = $('#address').val();
        //TODO : update with address2 field
        address.Address2 = $('#address').val();
        address.GuestID = window.GuestCheckinManager.BookingDto.GuestId ? window.GuestCheckinManager.BookingDto.GuestId : -1;
        address.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
        address.IsActive = true;
        address.CreatedBy = getCreatedBy();
        //TODO: addresstype to be selected from address type ddl
        //address.AddressTypeID = window.GuestCheckinManager.BookingDto.AddressTypeId ? window.GuestCheckinManager.BookingDto.AddressTypeId : -1;
        address.AddressTypeID = 1;

        addresses.push(address);
        return addresses;
    }

    function prepareGuest() {
        var guests = [];
        var guest = {};

        // for new guest guestid should be -1 else guestid
        guest.Id = window.GuestCheckinManager.BookingDto.GuestId ? window.GuestCheckinManager.BookingDto.GuestId : -1;
        guest.FirstName = $('#fName').val();
        guest.LastName = $('#lName').val();
        guest.MobileNumber = $('#phone').val();
        guest.EmailAddress = $('#email').val();
        guest.DOB = $('#dob').val();
        guest.Gender = $('#ddlInitials').val();

        var files = $("#uploadPhoto").get(0).files;
        if (files.length > 0) {
            guest.PhotoPath = window.guestIdPath + window.uploadDirectory + "\\" + files[0].name;
        } else {
            guest.PhotoPath = "No Image Available";
        }

        guest.IsActive = true;
        guest.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
        guest.CreatedBy = getCreatedBy();

        guests.push(guest);
        return guests;
    }

    function prepareGuestMapping() {
        var guestMapping = {};
        var guestMappings = [];

        guestMapping.Id = window.GuestCheckinManager.BookingDto.GuestMappingId ? window.GuestCheckinManager.BookingDto.GuestMappingId : -1;
        guestMapping.GUESTID = window.GuestCheckinManager.BookingDto.GuestId ? window.GuestCheckinManager.BookingDto.GuestId : -1;
        guestMapping.IDTYPEID = $('#ddlIdType').val();
        guestMapping.IDDETAILS = $('#idDetails').val();
        guestMapping.IdExpiryDate = $('#idExpiry').val();
        guestMapping.IdIssueState = $("#ddlIdState option:selected").text();
        guestMapping.IdIssueCountry = $("#ddlIdCountry option:selected").text();
        guestMapping.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
        guestMapping.IsActive = true;
        guestMapping.CreatedBy = getCreatedBy();

        guestMappings.push(guestMapping);
        return guestMappings;
    }

    function prepareAdditionalGuest() {
        var additionalGuests = [];
        var additionalGuestHtmlCol = $('.add-details');
        if (!additionalGuestHtmlCol || additionalGuestHtmlCol.length <= 0) return additionalGuests;
        for (var i = 0; i < additionalGuestHtmlCol.length; i++) {
            var additionalGuest = {};
            var divGuestDetails = additionalGuestHtmlCol[i];
            additionalGuest.Id = window.GuestCheckinManager.BookingDto.AdditionalGuestId ? window.GuestCheckinManager.BookingDto.AdditionalGuestId : -1;

            if ($('input#adFName') && $('input#adFName')[i]) {
                additionalGuest.FirstName = $('input#adFName')[i].value;
            }
            if ($('input#adLName') && $('input#adLName')[i]) {
                additionalGuest.LastName = $('input#adLName')[i].value;
            }

            if (additionalGuest.FirstName.trim() === '' || additionalGuest.LastName.trim() === '') continue;

            additionalGuest.IsActive = true;
            additionalGuest.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            additionalGuest.CreatedBy = getCreatedBy();
            //var files = $("#additionalUpload").get(0).files;
            //if (files.length > 0) {
            //    additionalGuest.GUESTIDPath = window.guestIdPath + window.uploadDirectory + "\\" + files[0].name;
            //} else {
            //    additionalGuest.GUESTIDPath = "No Image Available";
            //}
            additionalGuest.BookingId = window.GuestCheckinManager.BookingDto.BookingId ? window.GuestCheckinManager.BookingDto.BookingId : -1;
            additionalGuests.push(additionalGuest);
        }
        return additionalGuests;
    }

    function preparePaymentDetailForPrint(totalCharges) {
        var paymentDetail = [];
        var paymentTypeCol = $("td[id*='tdPaymentMode']");
        var paymentTypeColNew = $("td[id*='tdPaymentMode'] select");
        var paymentValueCol = $("td[id*='tdPaymentValue']");
        var paymentValueColNew = $("td[id*='tdPaymentValue'] input");
        var valueIdx = 0;
        var typeIdx = 0;
        var balance = 0;
        if (paymentValueCol && paymentValueCol.length > 0) {
            for (var i = 0; i < paymentValueCol.length; i++) {
                if (!paymentValueCol[i] || !paymentTypeCol[i]) continue;
                var value = 0;
                var paymentType = '';

                paymentType = paymentTypeCol[i].innerText;
                if (paymentType.trim() === "" || paymentType.indexOf("Select") >= 0) {
                    var selectedIdx = paymentTypeColNew[typeIdx].options.selectedIndex;
                    if (paymentTypeColNew[typeIdx].options[selectedIdx].value <= -1) continue;
                    paymentType = paymentTypeColNew[typeIdx].options[selectedIdx].text;
                    typeIdx++;
                }

                value = paymentValueCol[i].innerText;
                if (value.trim() === "") {
                    value = paymentValueColNew[valueIdx].value;
                    valueIdx++;
                    if (value.trim() === "") {
                        value = 0;
                    }
                    if (parseFloat(value) <= 0) continue;
                }

                var payment = {};
                payment.PaymentMode = paymentType;
                payment.PaymentValue = value;
                payment.IsActive = true;
                payment.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
                payment.CreatedBy = getCreatedBy();
                payment.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;

                //AB 20171201
                //balance = parseFloat(balance) + parseFloat(value);
                //payment.Balance = parseFloat(totalCharges) - parseFloat(balance);
                //payment.InvoiceId = 1038;
                paymentDetail.push(payment);
            }
        }

        return paymentDetail;
    }

    function preparePaymentDetail() {
        var paymentDetail = [];
        var paymentTypeCol = $("td[id*='tdPaymentMode']");
        var paymentTypeColNew = $("td[id*='tdPaymentMode'] select");
        var paymentValueCol = $("td[id*='tdPaymentValue']");
        var paymentValueColNew = $("td[id*='tdPaymentValue'] input");
        var valueIdx = 0;
        var typeIdx = 0;
        if (paymentValueCol && paymentValueCol.length > 0) {
            for (var i = 0; i < paymentValueCol.length; i++) {
                if (!paymentValueCol[i] || !paymentTypeCol[i]) continue;
                var value = 0;
                var paymentType = '';

                paymentType = paymentTypeCol[i].innerText;
                if (paymentType.trim() === "" || paymentType.indexOf("Select") >= 0) {
                    var selectedIdx = paymentTypeColNew[typeIdx].options.selectedIndex;
                    if (paymentTypeColNew[typeIdx].options[selectedIdx].value <= -1) continue;
                    paymentType = paymentTypeColNew[typeIdx].options[selectedIdx].text;
                    typeIdx++;
                }

                value = paymentValueCol[i].innerText;
                if (value.trim() === "") {
                    value = paymentValueColNew[valueIdx].value;
                    valueIdx++;
                    if (value.trim() === "") {
                        value = 0;
                    }
                    if (parseFloat(value) <= 0) continue;
                }

                var payment = {};
                payment.PaymentMode = paymentType;
                payment.PaymentValue = value;
                payment.IsActive = true;
                payment.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
                payment.CreatedBy = getCreatedBy();
                payment.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;
                //payment.InvoiceId = 1038;
                if (paymentType.trim() === '') {
                    alert('Select proper payment type.Hence invoice can not be added');
                    return;
                }
                paymentDetail.push(payment);
            }
        }

        return paymentDetail;
    }

    function prepareOtherCharges() {
        var invoiceItem = [];
        var htmlElementCol = $("tr#trOthertax");
        if (htmlElementCol && htmlElementCol.length > 0) {
            for (var i = 0; i < htmlElementCol.length; i++) {
                if (!htmlElementCol[i] || htmlElementCol[i].style.display === 'none' ||
                    !htmlElementCol[i].children[1].innerText || !htmlElementCol[i].children[2].firstElementChild.value ||
                    parseFloat(htmlElementCol[i].children[2].firstElementChild.value, 10).toFixed(2) <= 0) continue;

                var otherTax = {};
                var name = htmlElementCol[i].children[1].innerText;
                var value = parseFloat(htmlElementCol[i].children[2].firstElementChild.value, 10).toFixed(2);
                otherTax.ItemName = name;
                otherTax.ItemValue = value;
                otherTax.IsActive = true;
                otherTax.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
                otherTax.CreatedBy = getCreatedBy();
                otherTax.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;
                otherTax.ItemType = 'otheritem';
                //otherTax.InvoiceId = 1038;
                invoiceItem.push(otherTax);
            }
        }

        var baseRoomCharge = {};
        baseRoomCharge.ItemName = $('#baseRoomCharge')[0].name;
        baseRoomCharge.ItemValue = $("#baseRoomCharge").val();
        baseRoomCharge.IsActive = true;
        baseRoomCharge.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
        baseRoomCharge.CreatedBy = getCreatedBy();
        baseRoomCharge.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;
        //baseRoomCharge.InvoiceId = 1038;

        invoiceItem.push(baseRoomCharge);

        var totalRoomCharge = {};
        totalRoomCharge.ItemName = $('#totalRoomCharge')[0].name;
        totalRoomCharge.ItemValue = $("#totalRoomCharge").val();
        totalRoomCharge.IsActive = true;
        totalRoomCharge.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
        totalRoomCharge.CreatedBy = getCreatedBy();
        totalRoomCharge.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;
        //totalRoomCharge.InvoiceId = 1038;
        totalRoomCharge.ItemType = 'roomcharges';
        invoiceItem.push(totalRoomCharge);

        return invoiceItem;
    }

    function prepareTaxForPrint(totalRoomCharges) {
        var taxDetails = [];
        var balance = 0;
        var htmlElementCol = $("input[id*='taxVal']");
        if (!htmlElementCol || htmlElementCol.length <= 0) return taxDetails;

        for (var i = 0; i < htmlElementCol.length; i++) {
            if (!htmlElementCol[i] || !htmlElementCol[i].name) continue;
            var tax = {};

            var taxName = htmlElementCol[i].name;
            tax.TaxShortName = taxName;
            var taxValue = 0;
            var taxNameSelector = $('#' + taxName);
            var taxCalulatedSelector = $('#taxCalulatedVal' + taxName);
            if (!taxNameSelector[0].checked) {
                taxValue = 0;
            } else {
                taxValue = taxCalulatedSelector[0].value;
            }
            // TaxValue is absolute tax calculated
            tax.TaxValue = taxValue;
            tax.IsConsidered = taxNameSelector[0].checked;
            var taxPercent = htmlElementCol[i].value.replace('%', '');
            var taxValueInPercent = !taxPercent || isNaN(taxPercent) ? 0 : parseFloat(taxPercent, 10).toFixed(2);
            // TaxAmount is tax in percentage
            tax.TaxAmount = taxValueInPercent;

            tax.IsActive = true;
            tax.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            tax.CreatedBy = getCreatedBy();
            tax.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;

            //AB 20171201
            //balance = parseFloat(balance) + parseFloat(taxValue);
            //tax.Balance = parseFloat(balance) + parseFloat(totalRoomCharges);
            //tax.InvoiceId = 1038;
            taxDetails.push(tax);
        }
        return taxDetails;
    }

    function prepareTax() {
        var taxDetails = [];
        var htmlElementCol = $("input[id*='taxVal']");
        if (!htmlElementCol || htmlElementCol.length <= 0) return taxDetails;

        for (var i = 0; i < htmlElementCol.length; i++) {
            if (!htmlElementCol[i] || !htmlElementCol[i].name) continue;
            var tax = {};

            var taxName = htmlElementCol[i].name;
            tax.TaxShortName = taxName;
            var taxValue = 0;
            var taxNameSelector = $('#' + taxName);
            var taxCalulatedSelector = $('#taxCalulatedVal' + taxName);
            if (!taxNameSelector[0].checked) {
                taxValue = 0;
            } else {
                taxValue = parseFloat(taxCalulatedSelector[0].value, 10).toFixed(2);
            }
            // TaxValue is absolute tax calculated
            tax.TaxValue = taxValue;
            tax.IsConsidered = taxNameSelector[0].checked;
            var taxPercent = htmlElementCol[i].value.replace('%', '');
            var taxValueInPercent = !taxPercent || isNaN(taxPercent) ? 0 : parseFloat(taxPercent, 10).toFixed(2);
            // TaxAmount is tax in percentage
            tax.TaxAmount = taxValueInPercent;

            tax.IsActive = true;
            tax.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
            tax.CreatedBy = getCreatedBy();
            tax.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;
            //tax.InvoiceId = 1038;
            taxDetails.push(tax);
        }
        return taxDetails;
    }

    function prepareRoomBooking() {
        var roomBookings = [];
        var roomBooking = {};
        var roomType = $('#roomTypeDdl').val();
        roomBooking.RoomId = $('#roomddl').val();
        roomBooking.GuestID = window.GuestCheckinManager.BookingDto.GuestId ? window.GuestCheckinManager.BookingDto.GuestId : -1;
        // for new booking id = -1
        roomBooking.BookingId = window.GuestCheckinManager.BookingDto.BookingId ? window.GuestCheckinManager.BookingDto.BookingId : -1;
        roomBooking.Id = window.GuestCheckinManager.BookingDto.RoomBookingId ? window.GuestCheckinManager.BookingDto.RoomBookingId : -1;
        roomBooking.CreatedOn = window.GuestCheckinManager.GetCurrentDate();
        roomBooking.IsActive = true;
        roomBooking.CreatedBy = getCreatedBy();
        roomBooking.IsExtra = false;

        roomBookings.push(roomBooking);
        return roomBookings;
    }

    function getAllGuest() {
        var guestData = pmsSession.GetItem("guestinfo");
        if (!guestData) {
            // get guest by api calling  
            pmsService.GetAllGuest(args);
        }
    }

    function getCreatedBy() {
        return window.PmsSession.GetItem("username");
    }

    function bindGuestHistory(data) {
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

    function formatAMPM(date) {
        var dd = new Date(date);
        var hours = dd.getHours();
        var minutes = dd.getMinutes();
        var ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        minutes = minutes < 10 ? '0' + minutes : minutes;
        var strTime = hours + ':' + minutes + ' ' + ampm;
        return date.split(' ')[0] + ' ' + strTime;
    }

    win.GuestCheckinManager = guestCheckinManager;
}(window));