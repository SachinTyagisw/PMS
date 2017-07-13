// @summary: Observer pattern for client-side javascript code.
// This allows any code to "observer/subscribe" to a specific event
var Notifications =
{
    Callbacks: {},
    FiredNotifications: {},


    // @summary: Register a callback to the specified eventname.
    Subscribe: function(eventName, callback, isCancellable) {
        var callbacks = this.Callbacks[eventName];
        if (!callbacks) {
            callbacks = [];
            this.Callbacks[eventName] = callbacks;
        }
        // Add the callback to the list callbacks subscribing to this event name.
        callbacks.push({
            callback: callback,
            isCancellable: isCancellable
        });
    },
    
    // @summary: Registers a callback to the specified eventName
    // However, if the event has already fired, calls the callback immediately
    SubscribeActive: function (eventName, callback, isCancellable) {
        var notifications = this;

        // Has the requested event fired
        var firedNotification = notifications.FiredNotifications[eventName];
        if (firedNotification && typeof(callback) === "function") {
            callback(firedNotification.sender, firedNotification.args);
            return;
        } 
        
        notifications.Subscribe(eventName, callback, isCancellable);
    },

    // @summary: Unregister a callback to the specified eventname.
    Remove: function(eventName, callbackObject) {
        // If the callback not in the right format / not-available, do nothing
        if (!callbackObject || !callbackObject.callback) return;

        // if event not registered, do nothing
        var callbacks = this.Callbacks[eventName];
        if (!callbacks) return;

        // In the callbacks array find the callback we want to unregister
        var callbackIndex = -1;
        for (var i = 0; i < callbacks.length; i++) {
            if (!callbacks[i] || !callbacks[i].callback || callbacks[i].callback != callbackObject.callback) continue;
            callbackIndex = i;
            break;
        }

        if (callbackIndex <= -1) return; // not found
        callbacks.splice(callbackIndex, 1);
    },

    // @summary: Sends a message to all the callbacks subscribing to the event name.
    Notify: function (eventName, sender, args) {
        // Store the notification
        var notifications = this;
        notifications.FiredNotifications[eventName] = {"sender": sender, "args": args};

        // If no callbacks registered for this event
        var callbacks = this.Callbacks[eventName];
        if (!callbacks) {
            // No one to notify (hence execution will continue)
            return NotificationResults.Continue;
        }

        // Notify each of the callbacks subscribing to this event name.
        for (var ndx = 0; ndx < callbacks.length; ndx++) {
            // Verify callback settings is present
            var callbackSettings = callbacks[ndx];
            if (!callbackSettings) continue;
            if (typeof callbackSettings.callback != "function") continue;

            // Execute the callback
            var callbackResult = callbackSettings.callback(sender, args);
            if (this.ShouldCancel(callbackResult, callbackSettings.isCancellable))
                return NotificationResults.Cancel;
        }

        // None of the event handlers cancelled the event
        return NotificationResults.Continue;
    },

    // @summary: Checks if the given callback has been registered already for the given event
    IsSubscribed: function(eventName, callback) {
        var callbacks = this.Callbacks[eventName];
        if (!callbacks) return false;

        for (var i = 0; i < callbacks.length; i++) {
            if (callback === callbacks[i]) return true;
        }

        return false; // no match found
    },

    ShouldCancel: function(result, isCancellable) {
        // Cannot cancel a non-cancellable event
        if (!isCancellable) return false;

        // Cancel the event if result is break
        return (result === NotificationResults.Cancel);
    }
};

var NotificationResults = {
    Cancel: false,
    Continue: 1
};
