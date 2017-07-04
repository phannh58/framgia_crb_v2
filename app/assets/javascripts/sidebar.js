//= require highlight_event

function load_highlight_event() {
  var date = $calendar.fullCalendar('getView').currentDate._d;
  var from = firstDateShow(date.getMonth(), date.getFullYear());
  var to = lastDateShow(date.getMonth(), date.getFullYear());

  var calendar_ids = [];
  $('.sidebar-calendars .div-box>div').not($('.uncheck')).each(function() {
    calendar_ids.push($(this).attr('data-calendar-id'));
  });

  var start_time_view = new Date(from);
  var end_time_view = new Date(to);
  $.ajax({
    url: '/events',
    data: {
      calendar_ids: calendar_ids,
      organization_id: org_id,
      start_time_view: moment.tz(formatDate(start_time_view), window.timezone).format(),
      end_time_view: moment.tz(formatDate(end_time_view), window.timezone).format()
    },
    dataType: 'json',
    success: function(response) {
      var dates = Events.getInstance();
      dates.clear();
      response.events.forEach(function(event) {
        var date = moment.tz(event.start_date, timezone).format('MM/DD/YYYY');
        dates.add(date);
      });
      $('#mini-calendar').datepicker('refresh');
    }
  });
}

function firstDateShow(month, year) {
  var firstDayOfWeek = 1;
  var firstDay = new Date(year, month, 1);
  var i = firstDay.getDate() - firstDay.getDay() - firstDayOfWeek;
  return firstDay.setDate(firstDay.getDate() + i);
}

function lastDateShow(month, year) {
  var lastDay = new Date(year, month + 1, 0);
  var lastDayOfWeek = 6;
  var i = lastDayOfWeek - lastDay.getDay();
  return lastDay.setDate(lastDay.getDate() + i);
}

function formatDate(value) {
  return moment(value).format('MM/DD/YYYY');
}

$(document).on('ready', function() {
  var $miniCalendar = $('#mini-calendar');
  var menuCalendar = $('#menu-of-calendar');

  if($miniCalendar) load_highlight_event();

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
      localStorage.setItem('currentSelectDate', dateText);
      var dateParse = Date.parse(dateText);
      $calendar.fullCalendar('gotoDate', new Date(dateParse));
      $(this).datepicker('setDate', new Date(dateParse));
    },
    onChangeMonthYear:function(y, m) {
      var selectedDate = $(this).datepicker('getDate');
      selectedDate.setDate(1);
      selectedDate.setMonth(m-1);
      selectedDate.setFullYear(y);
      var firstDay = firstDateShow(m-1,selectedDate.getFullYear());
      var lastDay = lastDateShow(m-1, selectedDate.getFullYear());
      load_event(firstDay,lastDay);
      $miniCalendar.datepicker('refresh');
      $(this).datepicker('setDate', selectedDate);
    }
  });

  function highlightDays(date) {
    var dates = Events.getInstance();
    for (var i = 0; i < dates.array.length; i++) {
      if (dates.array[i].toString() == formatDate(date)) {
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
      // hiddenDialog('new-event-dialog');
      // hiddenDialog('popup');
      // hiddenDialog('dialog-update-popup');
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
});
