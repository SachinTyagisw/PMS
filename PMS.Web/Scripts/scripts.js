(function ($) {
    "use strict";

    /*
    ------------------------------------------------
    Sidebar open close animated humberger icon
    ------------------------------------------------*/

    //$(".hamburger").on('click', function () {
    //    $(this).toggleClass("is-active");
    //});


    /*
    -------------------
    List item active
    -------------------*/
    $('.header li').on('click', function () {
        $(".header li.active").removeClass("active");
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


    //var open = false;

    //var openSidebar = function () {
    //    $('.chat-sidebar').addClass('is-active');
    //    $('.chat-sidebar-icon').addClass('is-active');
    //    open = true;
    //}
    //var closeSidebar = function () {
    //    $('.chat-sidebar').removeClass('is-active');
    //    $('.chat-sidebar-icon').removeClass('is-active');
    //    open = false;
    //}

    //$('.chat-sidebar-icon').on('click', function (event) {
    //    event.stopPropagation();
    //    var toggle = open ? closeSidebar : openSidebar;
    //    toggle();
    //});






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

    //$('[data-search]').on('keyup', function () {
    //    var searchVal = $(this).val();
    //    var filterItems = $('[data-filter-item]');

    //    if (searchVal != '') {
    //        filterItems.addClass('hidden');
    //        $('[data-filter-item][data-filter-name*="' + searchVal.toLowerCase() + '"]').removeClass('hidden');
    //    } else {
    //        filterItems.removeClass('hidden');
    //    }
    //});


        /*  Chackbox all
    ---------------------------------------*/

$("#checkAll").change(function () {
    $("input:checkbox").prop('checked', $(this).prop("checked"));
});

$('#toggle').click( function(){
    $(this).parent().toggleClass('width');
    $(this).children().toggleClass( 'fa-chevron-circle-left').toggleClass( 'fa-chevron-circle-right');
});
    /*  Data Table
    -------------*/

    //$('#bootstrap-data-table').DataTable();



//$( "#dateFrom" ).datetimepicker({
//    minDate: 0,
//    maxDate: "+2Y",
//	timeInput: true,
//	timeFormat: "hh:mm tt",
//	showHour: false,
//	showMinute: false,
//    onSelect: function( selectedDate ) {
//        $( "#dateTo" ).datetimepicker("option", "minDate", selectedDate );

//        setTimeout(function(){
//            $( "#dateTo" ).datetimepicker('show');
//            //$( "#dateTo" ).datepicker("option", "showAnim", 'slide');
//        }, 16);
//    }
//});
$( "#dateFrom, #dateTo" ).datetimepicker({
    maxDate: "+2Y",
    timeInput: true,
    timeFormat: "hh:mm tt",
    showHour: false,
    showMinute: false
});

$('#idExpiry, #dob').datepicker({
    changeMonth: true,
    changeYear: true
});
//document.querySelector(".hour-input").onchange = function () {
//    document.querySelector('.hour-dd').disabled = !this.checked;
//};

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
            uploadBtn.setAttribute('style', `background-image: url('${e.target.result}');`);
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

//$(function(){
//  $(window).scroll(function() {
//  	function footer()
//      {
//          var scroll = $(window).scrollTop();
//          if(scroll > 20)
//          {
//              $(".footer-nav").fadeIn("slow").addClass("show");
//          }
//          else
//          {
//              $(".footer-nav").fadeOut("slow").removeClass("show");
//          }

//          clearTimeout($.data(this, 'scrollTimer'));
//          $.data(this, 'scrollTimer', setTimeout(function() {
//              if ($('.footer-nav').is(':hover')) {
//  	        	footer();
//      		}
//          else
//          {
//          	$(".footer-nav").fadeOut("slow").removeClass("show");
//          }
//  		}, 2000));
//      }
//      footer();
//  });

//});

$(function () {
    $(".search").keyup(function () {
        var searchTerm = $(".search").val();
        var listItem = $('.results tbody').children('tr');
        var searchSplit = searchTerm.replace(/ /g, "'):containsi('")
    
      $.extend($.expr[':'], {'containsi': function(elem, i, match, array){
            return (elem.textContent || elem.innerText || '').toLowerCase().indexOf((match[3] || "").toLowerCase()) >= 0;
        }
      });
    
      $(".results tbody tr").not(":containsi('" + searchSplit + "')").each(function(e){
        $(this).attr('visible','false');
      });

      $(".results tbody tr:containsi('" + searchSplit + "')").each(function(e){
        $(this).attr('visible','true');
      });

      var jobCount = $('.results tbody tr[visible="true"]').length;
        $('.counter').text(jobCount + ' item');

      if(jobCount == '0') {$('.no-result').show();}
        else {$('.no-result').hide();}
	});

    //----------- Create Floor --------------//
    $("#createFloor thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
    $("#createFloor tbody tr").append('<td class="finalActionsCol"> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');

    $("#createFloor").on("click", ".fa-plus-circle", function () {
        $(this).closest('tr').after('<tr><td class="idRow" contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td class="finalActionsCol"><i class="fa fa-plus-circle" aria-hidden="true"></i> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td></tr>');
    });

    $("#createFloor #addRow").on("click", function () {
        $("#createFloor table").append('<tr><td class="idRow" contenteditable="false">-</td><td contenteditable="false">-</td><td class="finalActionsCol"><i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td></tr>');
    });

    $("#createFloor").on("click", ".fa-minus-circle", function () {
        //if (prompt("Are You Sure You Want to Delete this Row? Type 'yes' to Confirm this") == "yes") {
        $(this).closest('tr').remove();
        //} else { }
    });

    $("#createFloor").on("click", ".fa-pencil-square-o, .fa-floppy-o", function () {
        var thisRow = $(this).parent().siblings();
        var editOn = $(this).hasClass("editMode");

        $('td:last-child').attr('contenteditable', 'false');
        $('td:last-child').css('background-color', 'transparent');

        if (editOn == false) {
            $(thisRow).attr('contenteditable', 'true');
            $(thisRow).css({'border': '1px solid #000','background': 'rgba(255,255,255,0.7)', 'padding': '6px'});
            $(this).removeClass("fa-pencil-square-o");
            $(this).addClass("fa-floppy-o editMode");
        } else if (editOn == true) {
            $(thisRow).attr('contenteditable', 'false');
            $(thisRow).css('background-color', 'transparent');
            $(this).removeClass("fa-floppy-o editMode");
            $(this).addClass("fa-pencil-square-o");
        }
    });

    //----------- Create Rooms --------------//
    $("#createRooms thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
    $("#createRooms tbody tr").append('<td class="finalActionsCol"> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');

    $("#createRooms").on("click", ".fa-plus-circle", function () {
        $(this).closest('tr').after('<tr><td class="idRow" contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td class="finalActionsCol"><i class="fa fa-plus-circle" aria-hidden="true"></i> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td></tr>');
    });

    $("#createRooms #addRow").on("click", function () {
        $("#createRooms table").append('<tr><td class="idRow" contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td class="finalActionsCol"><i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td></tr>');
    });

    $("#createRooms").on("click", ".fa-minus-circle", function () {
        //if (prompt("Are You Sure You Want to Delete this Row? Type 'yes' to Confirm this") == "yes") {
        $(this).closest('tr').remove();
        //} else { }
    });

    $("#createRooms").on("click", ".fa-pencil-square-o, .fa-floppy-o", function () {
        var thisRow = $(this).parent().siblings();
        var editOn = $(this).hasClass("editMode");

        $('td:last-child').attr('contenteditable', 'false');
        $('td:last-child').css('background-color', 'transparent');

        if (editOn == false) {
            $(thisRow).attr('contenteditable', 'true');
            $(thisRow).css({ 'border': '1px solid #000', 'background': 'rgba(255,255,255,0.7)', 'padding': '6px' });
            $(this).removeClass("fa-pencil-square-o");
            $(this).addClass("fa-floppy-o editMode");
        } else if (editOn == true) {
            $(thisRow).attr('contenteditable', 'false');
            $(thisRow).css('background-color', 'transparent');
            $(this).removeClass("fa-floppy-o editMode");
            $(this).addClass("fa-pencil-square-o");
        }
    });


    //----------- Create Rate Types --------------//
    $("#createRateTypes thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
    $("#createRateTypes tbody tr").append('<td class="finalActionsCol"> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');

    $("#createRateTypes").on("click", ".fa-plus-circle", function () {
        $(this).closest('tr').after('<tr><td class="idRow" contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td class="finalActionsCol"><i class="fa fa-plus-circle" aria-hidden="true"></i> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td></tr>');
    });

    $("#createRateTypes #addRow").on("click", function () {
        $("#createRateTypes table").append('<tr><td class="idRow" contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td class="finalActionsCol"><i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td></tr>');
    });

    $("#createRateTypes").on("click", ".fa-minus-circle", function () {
        //if (prompt("Are You Sure You Want to Delete this Row? Type 'yes' to Confirm this") == "yes") {
        $(this).closest('tr').remove();
        //} else { }
    });

    $("#createRateTypes").on("click", ".fa-pencil-square-o, .fa-floppy-o", function () {
        var thisRow = $(this).parent().siblings();
        var editOn = $(this).hasClass("editMode");

        $('td:last-child').attr('contenteditable', 'false');
        $('td:last-child').css('background-color', 'transparent');

        if (editOn == false) {
            $(thisRow).attr('contenteditable', 'true');
            $(thisRow).css({ 'border': '1px solid #000', 'background': 'rgba(255,255,255,0.7)', 'padding': '6px' });
            $(this).removeClass("fa-pencil-square-o");
            $(this).addClass("fa-floppy-o editMode");
        } else if (editOn == true) {
            $(thisRow).attr('contenteditable', 'false');
            $(thisRow).css('background-color', 'transparent');
            $(this).removeClass("fa-floppy-o editMode");
            $(this).addClass("fa-pencil-square-o");
        }
    });

    //----------- Manage Room Rates --------------//
    $("#manageRoomRates thead tr:first-child").append('<th class="actionsCol" contenteditable="false">Actions</th>');
    $("#manageRoomRates tbody tr").append('<td class="finalActionsCol"> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td>');

    $("#manageRoomRates").on("click", ".fa-plus-circle", function () {
        $(this).closest('tr').after('<tr><td class="idRow" contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td class="finalActionsCol"><i class="fa fa-plus-circle" aria-hidden="true"></i> <i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td></tr>');
    });

    $("#manageRoomRates #addRow").on("click", function () {
        $("#manageRoomRates table").append('<tr><td class="idRow" contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td contenteditable="false">-</td><td class="finalActionsCol"><i class="fa fa-minus-circle" aria-hidden="true"></i> <i class="fa fa-pencil-square-o" aria-hidden="true"></i> </td></tr>');
    });

    $("#manageRoomRates").on("click", ".fa-minus-circle", function () {
        //if (prompt("Are You Sure You Want to Delete this Row? Type 'yes' to Confirm this") == "yes") {
        $(this).closest('tr').remove();
        //} else { }
    });

    $("#manageRoomRates").on("click", ".fa-pencil-square-o, .fa-floppy-o", function () {
        var thisRow = $(this).parent().siblings();
        var editOn = $(this).hasClass("editMode");

        $('td:last-child').attr('contenteditable', 'false');
        $('td:last-child').css('background-color', 'transparent');

        if (editOn == false) {
            $(thisRow).attr('contenteditable', 'true');
            $(thisRow).css({ 'border': '1px solid #000', 'background': 'rgba(255,255,255,0.7)', 'padding': '6px' });
            $(this).removeClass("fa-pencil-square-o");
            $(this).addClass("fa-floppy-o editMode");
        } else if (editOn == true) {
            $(thisRow).attr('contenteditable', 'false');
            $(thisRow).css('background-color', 'transparent');
            $(this).removeClass("fa-floppy-o editMode");
            $(this).addClass("fa-pencil-square-o");
        }
    });

    //$('#createRow, .trigger').click(function () {
    //    $('.modal-wrapper').toggleClass('open');
    //    $('.page-wrapper').toggleClass('blur');
    //    return false;
    //});
});
