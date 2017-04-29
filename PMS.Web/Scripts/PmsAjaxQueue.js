﻿(function (win) {
    function PmsAjaxQueue() {
        this.IsAjaxRequestInProgress = false;
        this.AjaxRequestQueue = new Array();
    }

    PmsAjaxQueue.prototype.AddToQueue = function (url, successCallback, failureCallback, completeCallback, postedData) {
        // create ajax request object to be served
        var ajaxRequest = {
            'url': url,
            'successCallback': successCallback,
            'failureCallback': failureCallback,
            'completeCallback': completeCallback,
            'postedData': postedData
        };

        // Add to queue
        this.AjaxRequestQueue.push(ajaxRequest);

        // If there is no currently executing ajax request.
        if (!this.IsAjaxRequestInProgress) {
            this.IsAjaxRequestInProgress = true;
            // Execute Ajax request
            ajaxExecute.call(this);
        }
    };

    function ajaxExecute() {
        var self = this;
        if (!self.AjaxRequestQueue.length) {
            return;
        }

        var request = self.AjaxRequestQueue[0];

        self.AjaxRequestQueue.splice(0, 1);
        if (request.postedData) {
            $.ajax({
                url: request.url,
                success: request.successCallback,
                type: "POST",
                contentType: "application/json",
                data: $.toJSON(request.postedData),
                error: request.failureCallback,
                complete: function () {
                    if (typeof request.completeCallback == 'function') {
                        // if complete callback is provided. call it
                        request.completeCallback.apply(this, arguments);
                    }

                    if (!self.AjaxRequestQueue.length) {
                        self.IsAjaxRequestInProgress = false;
                    }

                    // call ajaxExecute again to excute next item in queue
                    ajaxExecute.call(self);
                }
            });
        }
        else {
            $.ajax({
                url: request.url,
                success: request.successCallback,
                type: "GET",
                contentType: "application/json",
                error: request.failureCallback,
                complete: function () {
                    if (typeof request.completeCallback == 'function') {
                        // if complete callback is provided. call it
                        request.completeCallback.apply(this, arguments);
                    }

                    if (!self.AjaxRequestQueue.length) {
                        self.IsAjaxRequestInProgress = false;
                    }

                    // call ajaxExecute again to excute next item in queue
                    ajaxExecute.call(self);
                }
            });
        }
    }

    win.PmsAjaxQueue = PmsAjaxQueue;

}(window));