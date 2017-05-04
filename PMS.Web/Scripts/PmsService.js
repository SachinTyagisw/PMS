(function (win) {
    function PmsService() {

        this.Config = {
            BaseUrl: window.baseUrl
        };

        this.Handlers = {
            OnGetRoomTypeByPropertySuccess: null,
            OnGetRoomTypeByPropertyFailure: null,
            OnGetRateTypeByPropertySuccess: null,
            OnGetRateTypeByPropertyFailure: null,
            OnGetRoomByPropertySuccess: null,
            OnGetRoomByPropertyFailure: null,
            OnAddBookingSuccess: null,
            OnAddBookingFailure: null,
            OnUploadImageSuccess: null,
            OnUploadImageFailure: null,
        };

        this.UploadImage = function (args) {
            makeAjaxRequestForImage(args, "UploadImage", this, "api/v1/Image/UploadImage");
        };

        this.AddBooking = function (args) {
            makeAjaxRequestPost(args, "AddBooking", this, "api/v1/Booking/AddBooking");
        };

        this.GetRoomTypeByProperty = function (args) {
            makeAjaxRequestGet(args, "GetRoomTypeByProperty", this, "api/v1/Room/GetRoomTypeByProperty/" + args.propertyId);
        };

        this.GetRateTypeByProperty = function (args) {
            makeAjaxRequestGet(args, "GetRateTypeByProperty", this, "api/v1/Room/GetRateTypeByProperty/" + args.propertyId);
        };

        this.GetRoomByProperty = function (args) {
            makeAjaxRequestGet(args, "GetRoomByProperty", this, "api/v1/Room/GetRoomByProperty/" + args.propertyId);
        };

        function makeAjaxRequestGet(args, operationName, e, uri) {
            var url = e.Config.BaseUrl + uri;
            var successCallback = makeSuccessHandler(operationName, e);
            var failureCallback = makeFailureHandler(operationName, e);
            var completeCallback = makeCompleteHandler(operationName, e);

            if (win.PmsAjaxQueue != null) {
                win.PmsAjaxQueue.AddToQueue(url, successCallback, failureCallback, completeCallback);
                return;
            }

            if (e.AjaxRequestInProgress) {
                alert("An Ajax request is already in progress cannot start another one. Please wait and try again later");
                return;
            }

            $.ajax({
                url: url,
                success: successCallback,
                type: "GET",
                contentType: "application/json",
                error: failureCallback,
                complete: completeCallback
            });
        }

        function makeAjaxRequestForImage(args, operationName, e, uri) {
            var url = e.Config.BaseUrl + uri;
            var successCallback = makeSuccessHandler(operationName, e);
            var failureCallback = makeFailureHandler(operationName, e);
            var completeCallback = makeCompleteHandler(operationName, e);

            if (win.PmsAjaxQueue != null) {
                win.PmsAjaxQueue.AddToQueue(url, successCallback, failureCallback, completeCallback, args);
                return;
            }

            if (e.AjaxRequestInProgress) {
                alert("An Ajax request is already in progress cannot start another one. Please wait and try again later");
                return;
            }

            $.ajax({
                url: url,
                success: successCallback,
                type: "POST",
                contentType: false,
                processData: false,
                data: args,
                error: failureCallback,
                complete: completeCallback
            });
        }

        function makeAjaxRequestPost(args, operationName, e, uri) {
            var url = e.Config.BaseUrl + uri;
            var successCallback = makeSuccessHandler(operationName, e);
            var failureCallback = makeFailureHandler(operationName, e);
            var completeCallback = makeCompleteHandler(operationName, e);

            if (win.PmsAjaxQueue != null) {
                win.PmsAjaxQueue.AddToQueue(url, successCallback, failureCallback, completeCallback, args);
                return;
            }

            if (e.AjaxRequestInProgress) {
                alert("An Ajax request is already in progress cannot start another one. Please wait and try again later");
                return;
            }

            $.ajax({
                url: url,
                success: successCallback,
                type: "POST",
                contentType: "application/json",
                data: $.toJSON(args),
                error: failureCallback,
                complete: completeCallback
            });
        }

        function makeSuccessHandler(handlerName, e) {
            return function (data) {
                invokeHandler(e.Handlers["On" + handlerName + "Success"], data);
            };
        }

        function makeFailureHandler(handlerName, e) {
            return function (jqXhr, textStatus, errorThrown) {
                invokeHandler(e.Handlers["On" + handlerName + "Failure"], errorThrown, jqXhr.status);
            };
        }

        function makeCompleteHandler(handlerName, e) {
            return function (jqXhr) {
                invokeHandler(e.Handlers["On" + handlerName + "Complete"], jqXhr.status);
            };
        }

        function invokeHandler(handler, input, jqXhrStatus) {
            if (typeof handler === 'function') {
                handler(input, jqXhrStatus);
            }
        }
    }

win.PmsAjaxQueue = win.PmsAjaxQueue ? new win.PmsAjaxQueue() : null;
win.PmsService = PmsService;
}(window));