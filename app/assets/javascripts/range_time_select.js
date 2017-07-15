$(document).on('ready', function() {
  $('.datetime .time').timepicker({
    timeFormat: 'g:ia',
    scrollDefault: 'now'
  });

  $('.datetime .date').datepicker({
    dateFormat: 'dd-mm-yy',
    autoclose: true
  });

  $('.datetime').datepair();

  $(document).on('change', '.date-time', function() {
    var start_time = $('#start_time');
    var start_date = $('#start_date');
    var finish_time = $('#finish_time');
    var finish_date = $('#finish_date');
    var start_date_repeat = $('#start-date-repeat');
    var end_date_repeat =  $('#end-date-repeat');

    var start_datetime = start_date.val() + ' ' + start_time.val();
    var finish_datetime = finish_date.val() + ' ' + finish_time.val();

    $('#event_start_date').val(moment.tz(start_datetime, 'DD-MM-YYYY hh:mma', timezone).format());
    $('#event_finish_date').val(moment.tz(finish_datetime, 'DD-MM-YYYY hh:mma', timezone).format());

    var start_datetime_repeat = start_date_repeat.val() + ' ' + start_time.val();
    var end_datetime_repeat = end_date_repeat.val() + ' ' + finish_time.val();

    $('#event_start_repeat').val(moment.tz(start_datetime_repeat, 'DD-MM-YYYY hh:mma', timezone).format());
    $('#event_end_repeat').val(moment.tz(end_datetime_repeat, 'DD-MM-YYYY hh:mma', timezone).format());

    $('.all-day').show();
  });
});
