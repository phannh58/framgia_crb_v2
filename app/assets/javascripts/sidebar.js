$(document).on('ready', function() {
  var $miniCalendar = $('#mini-calendar');
  var menuCalendar = $('#menu-of-calendar');

  $('.fc-prev-button, .fc-next-button, .fc-today-button').click(function() {
    var moment = $calendar.fullCalendar('getDate');
    $miniCalendar.datepicker();
    $miniCalendar.datepicker('setDate', new Date(moment.format('MM/DD/YYYY')));
  });

  $miniCalendar.datepicker({
    dateFormat: 'DD, d MM, yy',
    showOtherMonths: true,
    selectOtherMonths: true,
    changeMonth: true,
    changeYear: true,
    beforeShowDay: highlightDays,
    onSelect: function(dateText) {
      hiddenDialog('new-event-dialog');
      hiddenDialog('popup');
      hiddenDialog('dialog-update-popup');
      var dateParse = Date.parse(dateText);
      $calendar.fullCalendar('changeView', (calendarViewContext == 'scheduler' ? 'timelineDay' : 'agendaDay'));
      $calendar.fullCalendar('gotoDate', new Date(dateParse));
      $(this).datepicker('setDate', new Date(dateParse));
    },
    onChangeMonthYear:function(y, m) {
      var selectedDate = $(this).datepicker('getDate');
      selectedDate.setDate(1);
      selectedDate.setMonth(m-1);
      selectedDate.setFullYear(y);
      $miniCalendar.datepicker('refresh');
      $(this).datepicker('setDate', selectedDate);
    }
  });

  function highlightDays(date) {
    var events = $calendar.fullCalendar('clientEvents');

    for (var i = 0; i < events.length; i++) {
      if (moment(events[i]._start).format('MM/DD/YYYY') == moment(date).format('MM/DD/YYYY')) {
        return [true, 'highlight'];
      }
    }
    return [true, ''];
  }

  $('.create').click(function() {
    if ($(this).parent().hasClass('open')) {
      $(this).parent().removeClass('open');
    } else {
      $(this).parent().addClass('open');
    }
  });

  $('.btn-show-popup').click(function() {
    if ($(this).parent().closest('div').hasClass('open')) {
      $(this).parent().closest('div').removeClass('open');
    } else {
      $(this).parent().closest('div').addClass('open');
      event.stopPropagation();
    }
  });

  $('.close-popup-organization').click(function() {
    if ($(this).closest('div.btn-group').hasClass('open')) {
      $(this).closest('div.btn-group').removeClass('open');
    } else {
      $(this).closest('div.btn-group').addClass('open');
      event.stopPropagation();
    }
  });

  $('#clst_my').click(function() {
    if ($('#collapse1').hasClass('in')) {
      $('#collapse1').removeClass('in');
      $('#my-zippy-arrow').removeClass('down');
    } else{
      $('#collapse1').addClass('in');
      $('#my-zippy-arrow').addClass('down');
    }
  });

  $('#clst_other').click(function() {
    if ($('#collapse2').hasClass('in')) {
      $('#collapse2').removeClass('in');
      $('#other-zippy-arrow').removeClass('down');
    } else {
      $('#collapse2').addClass('in');
      $('#other-zippy-arrow').addClass('down');
    }
  });

  $(document).keydown(function(e) {
    if (e.keyCode == 27) {
      $('#source-popup').removeClass('open');
      $('#sub-menu-my-calendar, #menu-of-calendar, #sub-menu-setting').removeClass('sub-menu-visible');
      $('#sub-menu-my-calendar, #menu-of-calendar, #sub-menu-setting').addClass('sub-menu-hidden');
      $('.list-group-item').removeClass('background-hover');
      $('.sub-list').removeClass('background-hover');
      hiddenDialog('new-event-dialog');
      hiddenDialog('popup');
      hiddenDialog('dialog-update-popup');
    }
  });

  $('#clst_my_menu').click(function(event) {
    var position = $('#clst_my_menu').offset();
    menuCalendar.removeClass('sub-menu-visible');
    menuCalendar.addClass('sub-menu-hidden');
    $('#source-popup').removeClass('open');
    $('#sub-menu-my-calendar').css({'top': position.top + 13, 'left': position.left});

    if ($('#sub-menu-my-calendar').hasClass('sub-menu-visible')) {
      $('#sub-menu-my-calendar').removeClass('sub-menu-visible');
      $('#sub-menu-my-calendar').addClass('sub-menu-hidden');
    } else{
      $('#sub-menu-my-calendar').removeClass('sub-menu-hidden');
      $('#sub-menu-my-calendar').addClass('sub-menu-visible');
    }
    event.stopPropagation();
  });

  $(document).click(function(event) {
    $('#sub-menu-my-calendar').removeClass('sub-menu-visible');
    $('#sub-menu-my-calendar').addClass('sub-menu-hidden');

    if (menuCalendar.length > 0 && !$(event.target).hasClass('clst-menu-child')) {
      menuCalendar.removeClass('sub-menu-visible');
      menuCalendar.addClass('sub-menu-hidden');
    }

    if (menuCalendar.hasClass('sub-menu-hidden')) {
      $('.list-group-item').removeClass('background-hover');
      $('.sub-list').removeClass('background-hover');
    }
  });

  $('.clst-menu-child').click(function() {
    var windowH = $(window).height();
    var position = $(this).offset();
    // if ($(this).find('.sub').length > 0)
    //   $('#create-sub-calendar').parent().addClass('hidden-menu');
    // else
    //   $('#create-sub-calendar').parent().removeClass('hidden-menu');

    $('#id-of-calendar').html($(this).attr('id'));
    var selectedColorId = $(this).attr('selected_color_id');

    var menu_height = menuCalendar.height();

    if ((position.top + 12 + menu_height) >= windowH ) {
      menuCalendar.css({'top': position.top - menu_height - 2, 'left': position.left});
    } else {
      menuCalendar.css({'top': position.top + 12, 'left': position.left});
    }

    if (menuCalendar.hasClass('sub-menu-visible')) {
      menuCalendar.removeClass('sub-menu-visible');
      menuCalendar.addClass('sub-menu-hidden');
      $(this).parent().removeClass('background-hover');
    } else {
      $('#menu-of-calendar div.bcp-selected').removeClass('bcp-selected');

      menuCalendar.removeClass('sub-menu-hidden');
      menuCalendar.addClass('sub-menu-visible');
      $('#menu-of-calendar div[data-color-id="'+ selectedColorId +'"] div').addClass('bcp-selected');

      $(this).parent().addClass('background-hover');
      var rel = $(this).attr('rel');
      $('input:checkbox[id=input-color-' + rel+ ']').prop('checked', true);
      $('#menu-calendar-id').attr('rel', $(this).attr('id'));
    }
  });

  $('#edit-calendar').click(function() {
    var id_calendar = $('#id-of-calendar').html();
    var edit_link = '/calendars/' + id_calendar.toString() + '/edit';
    $('#edit-calendar').attr('href', edit_link);
  });

  var mousewheelEvent = (/Firefox/i.test(navigator.userAgent))? 'DOMMouseScroll' : 'mousewheel';

  $miniCalendar.bind(mousewheelEvent, function(e) {
    if(e.originalEvent.wheelDelta > 60) {
      $('.ui-datepicker-next').click();
    } else {
      $('.ui-datepicker-prev').click();
    }
  });

  $('.fc-left').append($('#timezone-name'));
  $('.fc-right-left').removeClass('hidden');

  $calendar.bind(mousewheelEvent, function(e) {
    var view = $calendar.fullCalendar('getView');
    var event = window.event || e;
    var delta = event.detail ? event.detail*(-120) : event.wheelDelta;

    if (mousewheelEvent === 'DOMMouseScroll'){
      delta = event.originalEvent.detail ? event.originalEvent.detail*(-120) : event.wheelDelta;
    }

    if (view.name == 'month') {
      if (delta > 60) {
        $calendar.fullCalendar('next');
      } else {
        $calendar.fullCalendar('prev');
      }
      var moment = $calendar.fullCalendar('getDate');
      $miniCalendar.datepicker();
      $miniCalendar.datepicker('setDate', new Date(moment.format('MM/DD/YYYY')));
    }
  });

  $('.list-group').on('click', 'span', function() {
    userCalendar.calendar_id = $(this).attr('id');
  });

  $('#menu-of-calendar .ccp-rb-color').on('click', function() {
    userCalendar.color_id = $(this).data('color-id');
    userCalendar.updateColor();
  });

  $('.sidebar-calendars').on('click', '.div-box', function() {
    userCalendar.calendar_id = $('div', this).attr('data-calendar-id');
    userCalendar.updateState();
  });

  var userCalendar = {
    calendar_id: null,
    color_id: null,
    updateColor: function() {
      $.ajax({
        url: '/particular_calendars/' + userCalendar.calendar_id,
        method: 'PATCH',
        data: {user_calendar: {id: userCalendar.calendar_id, color_id: userCalendar.color_id}},
        dataType: 'json',
        success: function() {
          var dColor = $('div[data-calendar-id='+ userCalendar.calendar_id +']');
          dColor.removeClass('color-' + dColor.attr('data-color-id'));
          dColor.addClass('color-' + userCalendar.color_id);
          dColor.attr('data-color-id', userCalendar.color_id);

          $('span#' + userCalendar.calendar_id).attr('selected_color_id', userCalendar.color_id);
          $calendar.fullCalendar('removeEvents');
          $calendar.fullCalendar('refetchEvents');
        },
        errors: function() {
          alert('OHHH! Updating error!!!');
        }
      });
    },
    updateState: function() {
      var dColor = $('div[data-calendar-id='+ userCalendar.calendar_id +']');
      var uncheck = dColor.hasClass('uncheck');
      $.ajax({
        url: '/particular_calendars/' + userCalendar.calendar_id,
        method: 'PATCH',
        data: {user_calendar: {id: userCalendar.calendar_id, is_checked: uncheck}},
        dataType: 'json',
        success: function(data) {
          if (data.is_checked) {
            dColor.removeClass('uncheck');
            $calendar.fullCalendar('addEventSource', dColor.attr('google_calendar_id'));
          } else {
            dColor.addClass('uncheck');
            $calendar.fullCalendar('removeEventSource', dColor.attr('google_calendar_id'));
          }

          $calendar.fullCalendar('removeEvents');
          $calendar.fullCalendar('refetchEvents');
        },
        errors: function() {
          alert('OHHH! Updating error!!!');
        }
      });
    }
  };
});
