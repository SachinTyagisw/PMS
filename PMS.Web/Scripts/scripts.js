(function ($) {
    "use strict";

    /*
    ------------------------------------------------
    Sidebar open close animated humberger icon
    ------------------------------------------------*/

    $(".hamburger").on('click', function () {
        $(this).toggleClass("is-active");
    });


    /*
    -------------------
    List item active
    -------------------*/
    $('.header li, .sidebar li').on('click', function () {
        $(".header li.active, .sidebar li.active").removeClass("active");
        $(this).addClass('active');
    });

    $(".header li").on("click", function (event) {
        event.stopPropagation();
    });

    $(document).on("click", function () {
        $(".header li").removeClass("active");

    });



    /*
    -----------------
    Chat Sidebar
    ---------------------*/


    var open = false;

    var openSidebar = function () {
        $('.chat-sidebar').addClass('is-active');
        $('.chat-sidebar-icon').addClass('is-active');
        open = true;
    }
    var closeSidebar = function () {
        $('.chat-sidebar').removeClass('is-active');
        $('.chat-sidebar-icon').removeClass('is-active');
        open = false;
    }

    $('.chat-sidebar-icon').on('click', function (event) {
        event.stopPropagation();
        var toggle = open ? closeSidebar : openSidebar;
        toggle();
    });






    /* TO DO LIST
    --------------------*/
    $(".tdl-new").on('keypress', function (e) {
        var code = (e.keyCode ? e.keyCode : e.which);
        if (code == 13) {
            var v = $(this).val();
            var s = v.replace(/ +?/g, '');
            if (s == "") {
                return false;
            } else {
                $(".tdl-content ul").append("<li><label><input type='checkbox'><i></i><span>" + v + "</span><a href='#' class='ti-close'></a></label></li>");
                $(this).val("");
            }
        }
    });


    $(".tdl-content a").on("click", function () {
        var _li = $(this).parent().parent("li");
        _li.addClass("remove").stop().delay(100).slideUp("fast", function () {
            _li.remove();
        });
        return false;
    });

    // for dynamically created a tags
    $(".tdl-content").on('click', "a", function () {
        var _li = $(this).parent().parent("li");
        _li.addClass("remove").stop().delay(100).slideUp("fast", function () {
            _li.remove();
        });
        return false;
    });



    /*  Chat Sidebar User custom Search
    ---------------------------------------*/

    $('[data-search]').on('keyup', function () {
        var searchVal = $(this).val();
        var filterItems = $('[data-filter-item]');

        if (searchVal != '') {
            filterItems.addClass('hidden');
            $('[data-filter-item][data-filter-name*="' + searchVal.toLowerCase() + '"]').removeClass('hidden');
        } else {
            filterItems.removeClass('hidden');
        }
    });


        /*  Chackbox all
    ---------------------------------------*/

$("#checkAll").change(function () {
    $("input:checkbox").prop('checked', $(this).prop("checked"));
});


    /*  Data Table
    -------------*/

    //$('#bootstrap-data-table').DataTable();



$( "#dateFrom" ).datetimepicker({
    minDate: 0,
    maxDate: "+2Y",
	timeInput: true,
	timeFormat: "hh:mm tt",
	showHour: false,
	showMinute: false,
    onSelect: function( selectedDate ) {
        $( "#dateTo" ).datetimepicker("option", "minDate", selectedDate );

        setTimeout(function(){
            $( "#dateTo" ).datetimepicker('show');
            //$( "#dateTo" ).datepicker("option", "showAnim", 'slide');
        }, 16);
    }
});

$( "#dateTo" ).datetimepicker({
    maxDate: "+2Y",
    timeInput: true,
    timeFormat: "hh:mm tt",
    showHour: false,
    showMinute: false
});

$('#id-expiry, #dob').datepicker({
	changeMonth: true,
	changeYear: true
});

class PhotoSubmission {
    constructor() {
        const inputs = document.querySelectorAll('.js-photo_submit-input');

        for (var i = 0; i < inputs.length; i++) {
            inputs[i].addEventListener('change', this.uploadImage);
        }
    }

    uploadImage(e) {
        const fileInput = e.target;
        const uploadBtn = e.target.parentNode;
        const deleteBtn = e.target.parentNode.childNodes[7];

        const reader = new FileReader();

        reader.onload = function (e) {
            uploadBtn.setAttribute("style", "background-image: url('${e.target.result}');");
            uploadBtn.classList.add('photo_submit--image');
            fileInput.setAttribute('disabled', 'disabled');
        };

        reader.readAsDataURL(e.target.files[0]);

        deleteBtn.addEventListener('click', () => {
            uploadBtn.removeAttribute('style');
            uploadBtn.classList.remove('photo_submit--image');

            setTimeout(() => {
                fileInput.removeAttribute('disabled', 'disabled');
            }, 200);
        });
    }
};

new PhotoSubmission;

})(jQuery);

$(function(){
  $(window).scroll(function() {
  	function footer()
      {
          var scroll = $(window).scrollTop();
          if(scroll > 20)
          {
              $(".footer-nav").fadeIn("slow").addClass("show");
          }
          else
          {
              $(".footer-nav").fadeOut("slow").removeClass("show");
          }

          clearTimeout($.data(this, 'scrollTimer'));
          $.data(this, 'scrollTimer', setTimeout(function() {
              if ($('.footer-nav').is(':hover')) {
  	        	footer();
      		}
          else
          {
          	$(".footer-nav").fadeOut("slow").removeClass("show");
          }
  		}, 2000));
      }
      footer();
  });

});


