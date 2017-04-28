(function (win) {
    function PmsService() {

        this.Config = {
            BaseUrl: window.baseUrl
        };

        this.Handlers = {
            OnGetRoomTypeByPropertySuccess: null,
            OnGetRoomTypeByPropertyFailure: null,
            OnGetRoomByPropertySuccess: null,
            OnGetRoomByPropertyFailure: null,
        };

        this.GetRoomTypeByProperty = function (args) {
            makeAjaxRequestGet(args, "GetRoomTypeByProperty", this, "api/v1/Room/GetRoomTypeByProperty/" + args.propertyId);
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