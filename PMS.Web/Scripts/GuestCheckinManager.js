(function (win) {
    var pmsService = new window.PmsService();
    var pmsSession = window.PmsSession;
    var args = {};
    var isDdlCountryChange = null;
    var invoiceData = {};
    var guestCheckinManager = {

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

        Initialize: function () {
            ajaxHandlers();
            getRoomTypes();
            getRoomRateTypes();
            getCountry();
            getAllGuest();
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

        AddInvoice: function () {

            var invoiceRequestDto = {};
            invoiceRequestDto.Invoice = {};
            var invoice = {};

            invoice.InvoiceTaxDetails = [];
            invoice.InvoiceItems = [];
            invoice.InvoicePaymentDetails = [];

            invoice.PropertyId = getPropertyId();
            invoice.BookingId = 1065;//window.GuestCheckinManager.BookingDto.BookingId ? window.GuestCheckinManager.BookingDto.BookingId : -1;

            if (invoice.PropertyId <= -1 || invoice.BookingId <= -1) {
                alert('Invalid bookingid or propertyid.');
                return;
            }

            invoice.Id = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;            
            invoice.GuestId = 1055;//window.GuestCheckinManager.BookingDto.GuestId ? window.GuestCheckinManager.BookingDto.GuestId : -1;
            invoice.CreatedOn = getCurrentDate();
            invoice.IsActive = true;
            invoice.TotalAmount = $('#total') && $('#total')[0] ? $('#total')[0].innerText : 0;
            invoice.Discount = $('#discount') && $('#discount')[0] ? $('#discount')[0].value : 0;
            invoice.IsPaid = $('#balance') && $('#balance').val() > 0 ? false : true;
            invoice.CreatedBy = getCreatedBy();

            // predefined tax 
            invoice.InvoiceTaxDetails = prepareTax();
            // dynamic tax and other payment charges
            invoice.InvoiceItems = prepareOtherCharges();
            invoice.InvoicePaymentDetails = preparePaymentDetail();

            invoiceRequestDto.Invoice = invoice;
            // add invoice by api calling  
            pmsService.AddInvoice(invoiceRequestDto);
        },

        AddBooking: function (status) {        
            
            if (!validateInputs()) return;

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
            booking.CreatedOn = getCurrentDate();
            booking.Status = status;
            booking.IsActive = true;
            booking.ISHOURLYCHECKIN = $('#hourCheckin')[0].checked ? true : false;
            var noOfHours = $('#hoursComboBox').val();
            booking.HOURSTOSTAY = $('#hourCheckin')[0].checked && parseInt(noOfHours) > 0 ? parseInt(noOfHours) : 0;
            booking.CreatedBy = getCreatedBy();            

            booking.RoomBookings = prepareRoomBooking();
            booking.Guests = prepareGuest();
            booking.GuestMappings = prepareGuestMapping();
            booking.Addresses = prepareAddress();
            booking.AdditionalGuests = prepareAdditionalGuest();
            
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
            // if it is not getinvoice api call
            if (!data.Invoice || !data.Invoice.Id || data.Invoice.Id <= 0){
                data = appendTotalRoomCharge(data);
                divInvoice.html(invoiceTemplate.render(data));
            } else {
                divInvoice.html(invoiceTemplate.render(data.Invoice));
            }
            window.GuestCheckinManager.CalculateInvoice();
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

        CalculateInvoice: function () {
            var totalCharge = 0;
            var paymentAmt = 0;
            var stayDays = window.GuestCheckinManager.invoiceData.StayDays;
            var baseRoomCharge = $('#baseRoomCharge');
            var totalRoomCharge = $('#totalRoomCharge');
            var taxElementCol = $("input[id*='taxVal']");
            var otherTaxElementCol = $("input[id*='otherTaxVal']");
            var paymentElementCol = $("input[id*='paymentVal']");
            var invoiceObject = window.GuestCheckinManager.invoiceData.Invoice;
            
            if (invoiceObject && invoiceObject.Id && invoiceObject.Id > 0) {
                //TODO: remove hard coded value calculate staydays on client side
                stayDays = 4;                
            }

            //  tax charges calulations
            if (taxElementCol && taxElementCol.length > 0) {
                for (var i = 0; i < taxElementCol.length; i++) {
                    if (!taxElementCol[i] || !taxElementCol[i].value || isNaN(taxElementCol[i].value)) continue;
                    totalCharge = (parseFloat(totalCharge) + parseFloat(taxElementCol[i].value, 10)).toFixed(2);
                }
            }

            // other tax charges calulations
            if (otherTaxElementCol && otherTaxElementCol.length > 0) {
                for (var i = 0; i < otherTaxElementCol.length; i++) {
                    if (!otherTaxElementCol[i] || !otherTaxElementCol[i].value || isNaN(otherTaxElementCol[i].value)) continue;
                    totalCharge = (parseFloat(totalCharge) + parseFloat(otherTaxElementCol[i].value, 10)).toFixed(2);
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
            
            //  payment calulations
            if (paymentElementCol && paymentElementCol.length > 0) {
                for (var i = 0; i < paymentElementCol.length; i++) {
                    if (!paymentElementCol[i] || !paymentElementCol[i].value || isNaN(paymentElementCol[i].value)) continue;
                    paymentAmt = (parseFloat(paymentAmt) + parseFloat(paymentElementCol[i].value, 10)).toFixed(2);
                }
            }

            var balanceAmt = totalCharge - paymentAmt;
            $('#payment').val(paymentAmt);
            $('#balance').val(balanceAmt);
            $('#credit').val(balanceAmt);

            return totalCharge;
        },

        GetInvoiceById: function (invoiceId) {
            args.invoiceId = invoiceId;
            pmsService.GetInvoiceById(args);
        },

        GetPaymentCharges: function () {
            // get paymentCharge details by api calling 
            var paymentChargeRequestDto = {};
            paymentChargeRequestDto.PropertyId = getPropertyId();
        
            var dateFrom = $('#dateFrom').val();
            var dateTo = $('#dateTo').val();
            var roomType = $('#roomTypeDdl').val();
            var rateType = $('#rateTypeDdl').val();
            var noOfHours = $('#hoursComboBox').val();
        
            // TODO: remove hardcoded value
            //dateFrom = "06/12/2017 12:00 am";
            //dateTo = "06/16/2017 2:00 am";
            //roomType = 1;
            //rateType = 1;

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
    
    function getPropertyId() {
        window.GuestCheckinManager.BookingDto.PropertyId = pmsSession.GetItem("propertyid");
        return window.GuestCheckinManager.BookingDto.PropertyId;
    }

    function applyDiscount(totalCharge) {
        if (!totalCharge || isNaN(totalCharge)) return 0;
        var discount = $('#discount').val();
        discount = !discount || isNaN(discount) ? 0 : parseFloat(discount, 10).toFixed(2);
        totalCharge = (parseFloat(totalCharge) - parseFloat(discount)).toFixed(2);
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
        address.City = $('#ddlCity').val();
        address.State = $('#ddlState').val();
        address.Country = $('#ddlCountry').val();
        address.ZipCode = $('#zipCode').val();
        address.Address1 = $('#address').val();
        //TODO : update with address2 field
        address.Address2 = $('#address').val();
        address.GuestID = window.GuestCheckinManager.BookingDto.GuestId ? window.GuestCheckinManager.BookingDto.GuestId : -1;
        address.CreatedOn = getCurrentDate();
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
            guest.PhotoPath = "D:\\PMSHosted\\PMSApi\\UploadedFiles\\" + files[0].name;
        } else {
            guest.PhotoPath = "No Image Available";
        }
        
        guest.IsActive = true;
        guest.CreatedOn = getCurrentDate();
        guest.CreatedBy = getCreatedBy();        

        guests.push(guest);
        return guests;
    }

    function prepareGuestMapping() {
        var guestMapping = {};
        var guestMappings = [];

        guestMapping.Id = window.GuestCheckinManager.BookingDto.GuestMappingId ? window.GuestCheckinManager.BookingDto.GuestMappingId : -1;
        guestMapping.GUESTID = window.GuestCheckinManager.BookingDto.GuestId ? window.GuestCheckinManager.BookingDto.GuestId : -1;
        //$( "#ddlIdType option:selected" ).text();
        guestMapping.IDTYPEID = $('#ddlIdType').val();
        guestMapping.IDDETAILS = $('#idDetails').val();
        guestMapping.IdExpiryDate = $('#idExpiry').val();
        guestMapping.IdIssueState = $('#ddlIdState').val();
        guestMapping.IdIssueCountry = $('#ddlIdCountry').val();
        guestMapping.CreatedOn = getCurrentDate();
        guestMapping.IsActive = true;
        guestMapping.CreatedBy = getCreatedBy();        
        
        guestMappings.push(guestMapping);
        return guestMappings;
    }

    function prepareAdditionalGuest() {
        var additionalGuest = {};
        var additionalGuests = [];

        additionalGuest.Id = window.GuestCheckinManager.BookingDto.AdditionalGuestId ? window.GuestCheckinManager.BookingDto.AdditionalGuestId : -1;
        additionalGuest.BookingId = window.GuestCheckinManager.BookingDto.BookingId ? window.GuestCheckinManager.BookingDto.BookingId : -1;
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
        additionalGuest.CreatedBy = getCreatedBy();

        additionalGuests.push(additionalGuest);
        return additionalGuests;
    }
    
    function preparePaymentDetail() {
        var paymentDetail = [];
        var payment = {};
        var paymentTypeElementCol = $("select[id*='paymentTypeDdl']");
        var paymentMode = '';

        //  getting paymenttype
        if (paymentTypeElementCol && paymentTypeElementCol.length > 0) {
            for (var i = 0; i < paymentTypeElementCol.length; i++) {
                if (!paymentTypeElementCol[i] || !paymentTypeElementCol[i].options || paymentTypeElementCol[i].options.length <= 0) continue;
                var selectedIdx = paymentTypeElementCol[i].options.selectedIndex;
                if (paymentTypeElementCol[i].options[selectedIdx].value <= -1) continue;
                paymentMode = paymentTypeElementCol[i].options[selectedIdx].text + ',' + paymentMode;
            }
        }

        // TODO: retrieve it dynamically from UI
        payment.PaymentMode = paymentMode;
        payment.PaymentValue = $('#payment').val();
        payment.PaymentDetails = "50% payment is done.";
        payment.IsActive = true;
        payment.CreatedOn = getCurrentDate();
        payment.CreatedBy = getCreatedBy();
        payment.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;

        paymentDetail.push(payment);
        return paymentDetail;
    }

    function prepareOtherCharges() {
        var invoiceItem = [];
        var htmlElementCol = $("tr#trOthertax");
        if (htmlElementCol && htmlElementCol.length > 0) {
            for (var i = 0; i < htmlElementCol.length; i++) {
                if (!htmlElementCol[i] || htmlElementCol[i].style.display === 'none'
                   || !htmlElementCol[i].children[1].innerText || !htmlElementCol[i].children[2].firstElementChild.value
                   || parseFloat(htmlElementCol[i].children[2].firstElementChild.value, 10).toFixed(2) <= 0) continue;

                var otherTax = {};
                var name = htmlElementCol[i].children[1].innerText;
                var value = parseFloat(htmlElementCol[i].children[2].firstElementChild.value, 10).toFixed(2);
                otherTax.ItemName = name;
                otherTax.ItemValue = value;
                otherTax.IsActive = true;
                otherTax.CreatedOn = getCurrentDate();
                otherTax.CreatedBy = getCreatedBy();
                otherTax.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;

                invoiceItem.push(otherTax);
            }
        }       

        var baseRoomCharge = {};
        baseRoomCharge.ItemName = $('#baseRoomCharge')[0].name;
        baseRoomCharge.ItemValue = $("#baseRoomCharge").val();
        baseRoomCharge.IsActive = true;
        baseRoomCharge.CreatedOn = getCurrentDate();
        baseRoomCharge.CreatedBy = getCreatedBy();
        baseRoomCharge.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;

        invoiceItem.push(baseRoomCharge);

        var totalRoomCharge = {};
        totalRoomCharge.ItemName = $('#totalRoomCharge')[0].name;
        totalRoomCharge.ItemValue = $("#totalRoomCharge").val();
        totalRoomCharge.IsActive = true;
        totalRoomCharge.CreatedOn = getCurrentDate();
        totalRoomCharge.CreatedBy = getCreatedBy();
        totalRoomCharge.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;

        invoiceItem.push(totalRoomCharge);

        return invoiceItem;
    }
    
    function prepareTax() {
        var taxDetails = [];
        var htmlElementCol = $("input[id*='taxVal']");
        if (!htmlElementCol || htmlElementCol.length <= 0) return taxDetails;

        for (var i = 0; i < htmlElementCol.length; i++) {
            if (!htmlElementCol[i] || !htmlElementCol[i].name) continue;
            var tax = {};
            var taxName = htmlElementCol[i].name;
            var taxValue = !htmlElementCol[i].value || isNaN(htmlElementCol[i].value) ? 0 : parseFloat(htmlElementCol[i].value, 10).toFixed(2);
            tax.TaxShortName = taxName;
            tax.TaxAmount = taxValue;
            tax.IsActive = true;
            tax.CreatedOn = getCurrentDate();
            tax.CreatedBy = getCreatedBy();
            tax.InvoiceId = window.GuestCheckinManager.BookingDto.InvoiceId ? window.GuestCheckinManager.BookingDto.InvoiceId : -1;

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
        roomBooking.CreatedOn = getCurrentDate();
        roomBooking.IsActive = true;
        roomBooking.CreatedBy = getCreatedBy();
        roomBooking.IsExtra = false;

        roomBookings.push(roomBooking);
        return roomBookings;
    }

    function getRoomTypes() {
        args.propertyId = getPropertyId();
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
        args.propertyId = getPropertyId();
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
    //    args.propertyId = getPropertyId();
    //    var roomData = pmsSession.GetItem("roomdata");
    //    if (!roomData) {
    //        // get room by api calling  
    //        pmsService.GetRoomByProperty(args);
    //    }
    //}     

    function getCreatedBy() {
        //TODO : get createdby value from user session
        return "vipul";
    }

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
        window.GuestCheckinManager.BookingDto.GuestId = null;
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
                //TODO: fill data from success response
                //window.GuestCheckinManager.BookingDto.BookingId = data.ResponseObject;
                //window.GuestCheckinManager.BookingDto.GuestId = data.GuestId;
                // clearAllFields();
                // if booking id > 0 then enabled save invoice btn
                $('#saveInvoice').attr("disabled", false);
                var roomnumber = $('#roomddl').val();
                var fname = $('#fName').val();
                var lname = $('#lName').val();
                var initials = $('#ddlInitials')[0].selectedOptions[0].innerText;
                var message = 'Roomnumber ' + roomnumber + ' has been booked for ' + initials + ' ' + fname + ' ' + lname;
                alert(message);
                console.log(message);
                // if booking is successful then upload image
                uploadImage($("#uploadPhoto"));
                // clear guesthistory from session storage
                // TODO : clear only current booked guestid
                pmsSession.RemoveItem("guesthistory");
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

            var guestId = window.GuestCheckinManager.BookingDto.GuestId ? window.GuestCheckinManager.BookingDto.GuestId : -1;
            if (guestId === -1) return;

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
            window.GuestCheckinManager.invoiceData = null;
            window.GuestCheckinManager.invoiceData = data;
            window.GuestCheckinManager.PopulateCharges(data);
        };
        pmsService.Handlers.OnGetPaymentChargesFailure = function () {
            // show error log
            console.error("get PaymentCharges call failed");
        };

        pmsService.Handlers.OnAddInvoiceSuccess = function (data) {
            var status = data.StatusDescription.toLowerCase();
            if (status.indexOf("successfully") >= 0) {
                //window.GuestCheckinManager.BookingDto.InvoiceId = data.ResponseObject;
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
            window.GuestCheckinManager.invoiceData = null;
            window.GuestCheckinManager.invoiceData = data;
            window.GuestCheckinManager.PopulateCharges(data);
        };
        pmsService.Handlers.OnGetInvoiceByIdFailure = function () {
            // show error log
            console.error("get invoice call failed");
        };

        //pmsService.Handlers.OnGetRoomByPropertySuccess = function (data) {
        //    //storing room data into session storage
        //    pmsSession.SetItem("roomdata", JSON.stringify(data.Rooms));
        //};
        //pmsService.Handlers.OnGetRoomByPropertyFailure = function () {
        //    // show error log
        //    console.error("Get Room call failed");
        //};

        // ajax handlers end
    }

    win.GuestCheckinManager = guestCheckinManager;
}(window));
