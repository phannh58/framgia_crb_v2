//= require_self
//= require attendee_action
//= require event_action

$(document).on('ready', function() {
  var start_time = $('#start_time');
  var start_date = $('#start_date');
  var finish_time = $('#finish_time');
  var finish_date = $('#finish_date');
  var start_date_repeat = $('#start-date-repeat');
  var end_date_repeat =  $('#end-date-repeat');

  if (start_date.val().length === 0){
    $('.all-day').hide();
  }

  start_date_repeat.datepicker({
    dateFormat: 'dd-mm-yy',
    autoclose: true,
    onClose: function(date) {
      var startMomentDate = moment(date, 'DD-MM-YYYY');
      var endMomentDate = moment(end_date_repeat.val(), 'DD-MM-YYYY');

      if(startMomentDate.isValid() && endMomentDate.isValid()) {
        if (startMomentDate > endMomentDate) {
          alert(I18n.t('events.warning.start_date_less_than_end_date'));
          start_date_repeat.val('');
        }
      } else {
        alert('Input date is not valid');
      }
    }
  });

  end_date_repeat.datepicker({
    dateFormat: 'dd-mm-yy',
    autoclose: true,
    onClose: function(date) {
      var startMomentDate = moment(start_date_repeat.val(), 'DD-MM-YYYY');
      var endMomentDate = moment(date, 'DD-MM-YYYY');

      if(startMomentDate.isValid() && endMomentDate.isValid()) {
        if (startMomentDate > endMomentDate) {
          alert(I18n.t('events.warning.end_date_greater_than_start_date'));
          end_date_repeat.val('');
        }
      } else {
        alert('Input date is not valid');
      }
    }
  });

  if($('.edit_event').length > 0) {
    $('#start_date').datepicker('setDate', $('#start_date').val());
  }

  $('.btn-del').click(function() {
    var attendee = $(this).attr('id');
    var attendeeId = attendee.substr(4);
    var text = confirm(I18n.t('events.confirm.delete'));

    if (text === true) {
      $('.l-att-' + attendeeId).fadeOut();
      $.ajax({
        url: '/attendees/' + attendeeId,
        type: 'DELETE',
        dataType: 'text',
        error: function(text) {
          alert(text);
        }
      });
    }
  });

  if ($('#event_all_day').is(':checked')) {
    start_time.hide();
    finish_time.hide();
    checkAllday($('#event_all_day'));
  }

  $('.dialog-repeat-event').click(function() {
    showDialog('dialog-repeat-event-form');
    showSummaryByRepeatType();
  });

  $('#event_all_day').on('click', function() {
    checkAllday($(this));
  });

  $('#event_repeat_type').on('change', function() {
    showRepeatOn();
    showSummaryByRepeatType();
  });

  $('#event_repeat_every').on('change', function() {
    showSummaryByRepeatType();
  });

  $('#end-date-repeat').on('change', function() {
    showSummaryByRepeatType();
  });

  $('#days-of-week').on('change', function() {
    showSummaryByRepeatType();
  });

  function showSummaryByRepeatType() {
    var summary = '';
    var day_on_show = '';
    var count_checked_day = 0;
    var repeat_daily = 'daily';
    var repeat_weekly = 'weekly';
    var repeat_monthly = 'monthly';
    var repeat_yearly = 'yearly';
    var repeat_type = $('#event_repeat_type').val();
    var repeat_every = $('#event_repeat_every').val();
    var start_date = $('#start-date-repeat').val();
    var end_date = $('#end-date-repeat').val();
    var checkboxes = $('#days-of-week').find('input[type = "checkbox"]');
    var start_repeat_format = moment(start_date, I18n.t('events.format_date_month_year'));
    var end_repeat_format = moment(end_date, I18n.t('events.format_date_month_year'))
                              .format(I18n.t('events.format_name_of_day'));

    for (var i = 0; i < checkboxes.length; i++) {
      if (checkboxes[i].checked == true) {
        count_checked_day += 1;
        day_on_show += $('#label-'+ i).text().replace(/\s+/g, '') + ', ';
      }
    }

    switch (repeat_type) {
      case repeat_daily:
        if (repeat_every == 1) {
          summary = I18n.t('events.daily_until') + end_repeat_format;
          appendText();
        } else {
          summary = I18n.t('events.every') + repeat_every + I18n.t('events.days_until') +
            end_repeat_format;
          appendText();
        }
        break;
      case repeat_weekly:
        if (count_checked_day == 0) {
          day_on_show = start_repeat_format.format(I18n.t('events.format_day')) + ', ';
        }

        if (repeat_every == 1) {
          if (count_checked_day == 7) {
            summary = I18n.t('events.weekly_on_all_days') + end_repeat_format;
            appendText();
          } else {
            summary = I18n.t('events.weekly_on') + day_on_show + ' ' +
              I18n.t('events.until') + end_repeat_format;
            appendText();
          }
        } else {
          if (count_checked_day == 7) {
            summary = I18n.t('events.every') + repeat_every +
              I18n.t('events.weeks_on_all_days') + ' ' + end_repeat_format;
            appendText();
          } else {
            summary = I18n.t('events.every') + repeat_every + I18n.t('events.weeks_on') +
              day_on_show + ' ' + I18n.t('events.until') + end_repeat_format;
            appendText();
          }
        }
        break;
      case repeat_monthly:
        if (repeat_every == 1) {
          summary = I18n.t('events.monthly_on') +
            start_repeat_format.format(I18n.t('events.format_day_DD')) +
            ', ' + I18n.t('events.until') + end_repeat_format;
          appendText();
        } else {
          summary = I18n.t('events.every') + repeat_every + I18n.t('events.months_on') +
            start_repeat_format.format(I18n.t('events.format_day_DD')) + ', ' +
            I18n.t('events.until') + end_repeat_format;
          appendText();
        }
        break;
      case repeat_yearly:
        if (repeat_every == 1) {
          summary = I18n.t('events.annually_on') +
            start_repeat_format.format(I18n.t('events.format_month_day')) +
            ', ' + I18n.t('events.until') + end_repeat_format;
          appendText();
        } else {
          summary = I18n.t('events.every') + repeat_every + I18n.t('events.years_on') +
            start_repeat_format.format(I18n.t('events.format_month_day')) +
            ', ' + I18n.t('events.until') + end_repeat_format;
          appendText();
        }
        break;
    }

    function appendText() {
      $('#summary-result').empty();
      $('#summary-result').append(summary);
    }
  }

  function formatAMPM(date) {
    var hours = date.getHours();
    var minutes = date.getMinutes();
    var ampm = hours >= 12 ? 'pm' : 'am';
    hours = hours % 12;
    hours = hours ? hours : 12;
    minutes = minutes < 10 ? '0' + minutes : minutes;
    var strTime = hours + ':' + minutes + ampm;
    return strTime;
  }

  function checkAllday(element){
    if (element.is(':checked')) {
      start_time.hide();
      finish_time.hide();
      var start = new Date();
      start.setHours(0,0,0,0);
      var end = new Date();
      end.setHours(23,59,59,999);
      start_time.val(formatAMPM(start));
      finish_time.val(formatAMPM(end));
      $('#event_start_date').val(start_date.val() + ' ' + start_time.val());
      $('#event_finish_date').val(finish_date.val() + ' ' + finish_time.val());
    } else {
      start_time.show();
      finish_time.show();
    }
  }

  function clearDialog() {
    hiddenDialog('dialog-repeat-event-form');
    hiddenDialog('repeat-on');
    $('.overlay-bg').hide();
  }

  function uncheckRepeat() {
    $('input[type="checkbox"]#repeat').prop('checked', false);
  }

  function checkedRepeat() {
    $('input[type="checkbox"]#repeat').prop('checked', true);
  }

  var dialog_form = $('#dialog-repeat-event-form');

  if($('.cb-repeat').hasClass('repeat-on')) {
    $('.cb-repeat').removeClass('first');
    $('.dialog-repeat-event').show();
    checkedRepeat();
  } else {
    $('.dialog-repeat-event').hide();
  }

  $('input[type="checkbox"]#repeat').change(function() {
    if (this.checked && $('.cb-repeat').hasClass('first')) {
      enable_repeat_params();
      showRepeatOn();
      dialog_form.centerScreen();
      disabled_start_date();
      showDialog('dialog-repeat-event-form');
    }

    if (!$('.cb-repeat').hasClass('first')) {
      if (this.checked)
        $('.dialog-repeat-event').show();
      else
        $('.dialog-repeat-event').hide();
    }
  });

  function disabled_start_date() {
    if ($('#start_date').val().length > 0) {
      $('#start-date-repeat').val($('#start_date').val());
      $('#start-date-repeat').attr('disabled', 'disabled');
      $('#event_start_repeat').val($('#start_date').val());
    }
  }

  function enable_repeat_params() {
    $('#event_repeat_type, #event_repeat_every, #start-date-repeat, #end-date-repeat').prop('disabled', false);
  }

  function disable_repeat_params() {
    $('#event_repeat_type, #event_repeat_every, #start-date-repeat, #end-date-repeat').prop('disabled', true);
  }

  $('.dialog-repeat-event').click(function() {
    showRepeatOn();
    dialog_form.centerScreen();
    showDialog('dialog-repeat-event-form');
  });

  $('.done-repeat').click(function() {
    if ($('#start-date-repeat').val().length === 0) {
      $('#start-date-repeat').focus();
    } else if ($('#end-date-repeat').val().length === 0) {
      $('#end-date-repeat').focus();
    } else {
      clearDialog();
      $('.cb-repeat').removeClass('first');
      $('.dialog-repeat-event').show();
    }
  });

  $('.close-repeat-modal, .cancel-repeat').click(function() {
    if ($('.cb-repeat').hasClass('first')) {
      disable_repeat_params();
      uncheckRepeat();
    }
    clearDialog();
  });

  $('.overlay-bg').click(function(events) {
    events.preventDefault();
  });

  $(document).keyup(function(e) {
    if (e.keyCode != 27)
      e.preventDefault();
    else if ($('.cb-repeat').hasClass('first')) {
      disable_repeat_params();
      uncheckRepeat();
      clearDialog();
    }
  });

  // function checkedWeekly() {
  //   var repeatOn = $('#start-date-repeat').val().split('-');
  //   var splitRepeatOn = new Date(repeatOn[2], repeatOn[1] - 1, repeatOn[0]);
  //   var cb = $('#repeat-' + splitRepeatOn.getDay());
  //   cb.prop('checked', true);
  // }

  $.fn.centerScreen = function() {
    this.css('position', 'absolute');
    this.css('top', '44px');
    this.css('left', ($(window).width() - this.width()) / 2 + $ (window).scrollLeft() + 'px');
    return this;
  };

  function showRepeatOn() {
    var repeat_type = $('#event_repeat_type').val();
    var repeat_weekly = 'weekly';

    if(repeat_type == repeat_weekly){
      showDialog('repeat-on');
      //checkedWeekly();
    } else{
      hiddenDialog('repeat-on');
    }
  }

  $('#finish_date').change(function() {
    $('#start_date').val($('#finish_date').val());
  });

  $('#repeat').change(function() {
    if (!this.checked) {
      clearRepeatForm();
    }
  });

  function clearRepeatForm() {
    $('#event_repeat_type').val('daily');
    $('#event_repeat_every').val(1);
    $('#event_start_repeat').val($('#start_date').val());
    $('#start-date-repeat').attr('disabled', 'disabled');
    $('#end-date-repeat').val('');
    $('#repeat-on').find('input:checkbox').prop('checked', false);
  }

  $(document).on('click', '.btn-confirmation-repeat', function() {
    confirm_update_popup();
  });
});
