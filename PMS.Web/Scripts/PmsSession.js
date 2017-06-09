(function (win) {    

    var pmsSession = {

        CountrySessionKey: [],
        GuestSessionKey: [],
        StateSessionKey: [],

        SetItem: function (key, value) {
            if (typeof (Storage) !== "undefined") {
                // Code for localStorage/sessionStorage.
                window.sessionStorage.setItem(key , value);
            } else {
                // Sorry! No Web Storage support..
                console.log("Sorry! No Web Storage support..");
            }           
        },

        GetItem: function (key) {
            if (typeof (Storage) !== "undefined") {
                // Code for localStorage/sessionStorage.
                return window.sessionStorage.getItem(key);
            } else {
                // Sorry! No Web Storage support..
                console.log("Sorry! No Web Storage support..");
                return null;
            }
        },

        RemoveItem: function (key) {
            if (typeof (Storage) !== "undefined") {
                // Code for localStorage/sessionStorage.
                window.sessionStorage.removeItem(key);
            } else {
                // Sorry! No Web Storage support..
                console.log("Sorry! No Web Storage support..");
            }            
        }

    };
    win.PmsSession = pmsSession;
}(window));