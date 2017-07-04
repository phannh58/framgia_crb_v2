function eventData(data) {
  var start_time = moment(data.start_date).tz(timezone).format();
  var end_time = moment(data.finish_date).tz(timezone).format();
  var titleEvent = calendarViewContext === 'calendar' ? (data.calendar_name + ': ' + data.title) : data.title;

  return {
    id: data.id,
    title: titleEvent,
    summary: data.title,
    start: start_time,
    end: end_time,
    className: ['color-' + data.color_id, data.id],
    calendar_id: data.calendar_id,
    calendar_name: data.calendar_name,
    resourceId: data.calendar_id,
    allDay: data.all_day,
    repeat_type: data.repeat_type,
    start_repeat: data.start_repeat,
    end_repeat: data.end_repeat,
    event_id: data.event_id,
    exception_type: data.exception_type,
    exception_time: data.exception_time,
    editable: data.editable,
    persisted: data.persisted,
    isGoogleEvent: false,
    start_time_before_drag: start_time,
    finish_time_before_drag: end_time
  };
}

function initDialogEventClick(event, jsEvent){
  $('#popup').remove();

  hiddenDialog('new-event-dialog');
  hiddenDialog('google-event-popup');
  unSelectCalendar();

  if (event.isGoogleEvent) {
    updateGoogleEventPopupData(event);
    dialogCordinate(jsEvent, 'google-event-popup', 'gprong-popup');
  } else {
    var start_date = moment.tz(event.start.format(), 'YYYY-MM-DDTHH:mm:ss', timezone).format();
    var finish_date = event.end !== null ? moment.tz(event.end.format(), 'YYYY-MM-DDTHH:mm:ss', timezone).format() : '';
    $.ajax({
      url: '/events/' + event.event_id,
      dataType: 'json',
      data: {
        start_date: start_date,
        finish_date: finish_date,
      },
      success: function(data) {
        $calContent.append(data.popup_content);
        dialogCordinate(jsEvent, 'popup', 'prong-popup');
      },
      errors: function() {
        alert('OOP, Errors!!!');
      }
    });
  }
}

function unSelectCalendar() {
  $calendar.fullCalendar('unselect');
}

$(document).on('click', '#btn-delete-event', function(e) {
  e.preventDefault();
  hiddenDialog('popup');
  var _event = current_event();

  if (_event.repeat_type === null) {
    deleteServerEvent(_event, 'delete_all');
  } else if (_event.exception_type == 'edit_only') {
    deleteServerEvent(_event, 'delete_only');
  } else {
    confirm_delete_popup();
  }
});

$(document).on('click', '.close-dialog-popup', function(e) {
  if ($(e.target).attr('data-rerender-event') == 1) reRenderCurrentEvent();
  unSelectCalendar();
  hiddenDialog('popup');
  hiddenDialog('new-event-dialog');
  hiddenDialog('dialog-update-popup');
  hiddenDialog('dialog-delete-popup');
  hiddenDialog('google-event-popup');
  $('.overlay-bg').hide();
});

$(document).on('click', '.title-popup', function() {
  $('.data-display').css('display', 'none');
  $('.data-none-display').css('display', 'inline-block');
  var titleInput = $('.title-input-popup');
  titleInput.focus();
  titleInput.val(titleInput.attr('data-current-value'));
});

$(document).click(function(event) {
  if ($('.fc-view-container').length === 0)
    return;

  saveLastestView();

  if (!$(event.target).hasClass('create') && !$(event.target).closest('#event-popup').hasClass('dropdown-menu')) {
    $('#source-popup').removeClass('open');
  }

  if ($(event.target).closest('#new-event-dialog').length === 0 && $(event.target).closest('.fc-body').length === 0) {
    hiddenDialog('new-event-dialog');
    unSelectCalendar();
  }

  if ($(event.target).closest('#popup').length === 0 && $(event.target).closest('.fc-body').length === 0) {
    hiddenDialog('popup');
  }

  if ($(event.target).closest('#dialog-delete-popup').length === 0 && $(event.target).closest('#btn-delete-event').length === 0) {
    hiddenDialog('dialog-delete-popup');
  }

  if($(event.target).closest('.fc-event').length === 0 && $(event.target).closest('#google-event-popup').length === 0) {
    hiddenDialog('google-event-popup');
  }
});

function saveLastestView() {
  localStorage.setItem('currentView', $calendar.fullCalendar('getView').name);
}

function updateGoogleEventPopupData(event) {
  $('.gtitle-popup span').html(event.title);
  $('.gevent-link').attr('href', event.link);
  var time_summary;

  if (event.allDay) {
    time_summary = event.start.format('MMMM Do YYYY');
  } else {
    time_summary = event.start.format('dddd') + ' ' + event.start.format('H:mm A') + ' To ' + event.end.format('H:mm A') + ' ' + event.end.format('DD-MM-YYYY');
  }

  $('.gtime-event-popup').html(time_summary);
  $('.gcalendar-event-popup').html(event.orgnaizer);
}

function confirm_delete_popup(){
  var dialog = $('#dialog-delete-popup');
  var dialogW = $(dialog).width();
  var windowW = $(window).width();
  var xCordinate;
  xCordinate = (windowW - dialogW) / 2;
  dialog.css({'top': 44, 'left': xCordinate});
  showDialog('dialog-delete-popup');
}

$(document).on('click', '.btn-confirm', function() {
  var rel = $(this).attr('rel');

  if (rel === undefined) return;

  var event = current_event();

  if (rel.indexOf(I18n.t('events.repeat_dialog.delete.delete')) !== -1) {
    deleteServerEvent(event, rel);
    hiddenDialog('dialog-delete-popup');
  } else if (rel.indexOf(I18n.t('events.repeat_dialog.edit.edit')) !== -1) {
    updateServerEvent(event, event.allDay, rel, 1);
    hiddenDialog('dialog-update-popup');
  }
  $('.overlay-bg').hide();
});

function deleteServerEvent(event, exception_type) {
  var start_date_before_delete, finish_date_before_delete;

  if (!event.allDay)
    finish_date_before_delete = event.finish_time_before_drag;

  start_date_before_delete = event.start_time_before_drag;

  if (event.end !== null)
    var finish_date = moment.tz(event.end.format(), 'YYYY-MM-DDTHH:mm:ss', timezone).format();

  $.ajax({
    url: '/events/' + event.event_id,
    type: 'DELETE',
    data: {
      exception_type: exception_type,
      exception_time: moment.tz(event.start.format(), 'YYYY-MM-DDTHH:mm:ss', timezone).format(),
      finish_date: finish_date,
      start_date_before_delete: start_date_before_delete,
      finish_date_before_delete: finish_date_before_delete,
      persisted: event.persisted ? 1 : 0
    },
    dataType: 'json',
    success: function() {
      if ($calendar.attr('data-reload-page') == 'false') {
        if (exception_type == 'delete_all_follow')
          $calendar.fullCalendar('removeEvents', function(e) {
            return (e.event_id === event.event_id && e.start >= event.start);
          });
        else if (exception_type == 'delete_all')
          $calendar.fullCalendar('removeEvents', function(e) {
            return (e.event_id === event.event_id);
          });
        else
          $calendar.fullCalendar('removeEvents', [event.id]);
      } else {
        window.history.back();
        location.reload();
      }
    },
    error: function() {
    }
  });
}

$(document).on('click', '#btn-save-event', function(e) {
  e.preventDefault();

  hiddenDialog('popup');
  var fevent = current_event();

  if (fevent.repeat_type === null || fevent.exception_type === 'edit_only') {
    var form = $(this).parents('form');
    $.ajax({
      url: form.attr('action'),
      type: 'POST',
      dataType: 'json',
      data: form.serialize(),
      success: function(data) {
        $calendar.fullCalendar('removeEvents', [fevent.id]);
        $calendar.fullCalendar('renderEvent', eventData(data), true);
      },
      error: function () {
        alert('Unexpected error!!!');
      }
    });
  } else {
    confirm_update_popup();
  }
});

$('form.event-form').submit(function(event) {
  event.preventDefault();

  var form = $(this);
  var submitDom = $(document.activeElement);

  if (submitDom.context.value.length > 0 ) {
    $('.exception_type').val(submitDom.context.value);
  }

  $.ajax({
    url: $(this).attr('action'),
    type: 'POST',
    dataType: 'json',
    data: $(this).serialize(),
    success: function(data) {
      if (data.is_overlap) {
        overlapConfirmation(form);
      } else if (data.is_errors) {
        var $errorsTitle = $('.error-title');
        $errorsTitle.text(I18n.t('events.dialog.title_error'));
        $errorsTitle.show();
      } else {
        if ($calendar.attr('data-reload-page') == 'false') {
          hiddenDialog('new-event-dialog');
          addEventToCalendar(data);
        } else {
          // window.history.back();
          // location.reload();
          var go_back_link = $('.btn-go-back')[0].href
          document.location.href = go_back_link ? go_back_link : '/';
        }
      }
    },
    error: function (jqXHR) {
      if (jqXHR.status === 500) {
        alert('Internal error: ' + jqXHR.responseText);
      } else {
        alert('Unexpected error!!!');
      }
    }
  });
});

function overlapConfirmation(form) {
  var dialogOverlapConfirm = $('#dialog_overlap_confirm');
  dialogOverlapConfirm.dialog({
    autoOpen: false,
    modal: true,
    closeOnEscape: false,
    resizable: false,
    height: 'auto',
    width: 400
  });
  dialogOverlapConfirm.dialog({
    buttons : {
      // 'Confirm' : function() {
      //   $('#allow-overlap').val('true');
      //   form.find('input[name="_method"]').remove();
      //   $.ajax({
      //     type: 'POST',
      //     url: '/events',
      //     dataType: 'json',
      //     data: form.serialize(),
      //     success: function(data) {
      //       if ($calendar.attr('data-reload-page') == 'false') {
      //         addEventToCalendar(data);
      //         $('#allow-overlap').val('false');
      //         dialogOverlapConfirm.dialog('close');
      //       } else {
      //         window.history.back();
      //       }
      //     },
      //     error: function (jqXHR) {
      //       if (jqXHR.status === 500) {
      //         alert('Internal error: ' + jqXHR.responseText);
      //       } else {
      //         alert('Unexpected error!');
      //       }
      //     }
      //   });
      // },
      'Cancel' : function() {
        $(this).dialog('close');
      }
    }
  });
  dialogOverlapConfirm.dialog('open');
}

function addEventToCalendar(data) {
  $calendar.fullCalendar('renderEvent', eventData(data), true);
  $calendar.fullCalendar('unselect');
}

function updateServerEvent(event, allDay, exception_type, is_drop) {
  var start_date, finish_date, start_date_with_timezone;

  if(event.title.length === 0)
    event.title = I18n.t('calendars.events.no_title');
  else
    event.title = $('.title-input-popup').val();


  start_date_with_timezone = moment.tz(event.start.format(), 'YYYY-MM-DDTHH:mm:ss', timezone);

  if (allDay) {
    start_date = start_date_with_timezone.startOf('day').format();
    finish_date = start_date_with_timezone.endOf('day').format();
  } else {
    start_date = start_date_with_timezone.format();

    if (event.end === null) {
      finish_date = start_date_with_timezone.add(2, 'hours').format();
    } else {
      finish_date = moment.tz(event.end.format(), 'YYYY-MM-DDTHH:mm:ss', timezone).format();
    }
  }

  var dataUpdate = {
    event: {
      title: event.title,
      start_date: start_date,
      finish_date: finish_date,
      all_day: allDay,
      exception_type: exception_type,
      end_repeat: event.end_repeat,
    },
    is_drop: is_drop,
    persisted: event.persisted ? 1 : 0,
    start_time_before_drag: event.start_time_before_drag,
    finish_time_before_drag: event.finish_time_before_drag
  };

  $.ajax({
    url: '/events/' + event.event_id,
    data: dataUpdate,
    type: 'PATCH',
    dataType: 'json',
    success: function(data) {
      if (exception_type == 'edit_all_follow' || exception_type == 'edit_all') {
        $calendar.fullCalendar('removeEvents');
        $calendar.fullCalendar('refetchEvents');
      } else {
        var fevent = current_event();
        $calendar.fullCalendar('removeEvents', [fevent.id]);
        $calendar.fullCalendar('renderEvent', eventData(data), true);
      }
    },
    error: function(data) {
      if (data.status == 422) {
        var dialogOverlap = $('#dialog_overlap_confirm');
        dialogOverlap.dialog({
          autoOpen: false,
          modal: true,
          closeOnEscape: false,
          resizable: false,
          height: 'auto',
          width: 400
        });
        dialogOverlap.dialog({
          buttons : {
            // 'Confirm' : function() {
            //   dataUpdate.allow_overlap = 'true';
            //   $.ajax({
            //     type: 'PATCH',
            //     url: '/events/' + event.event_id,
            //     dataType: 'json',
            //     data: dataUpdate,
            //     success: function() {
            //       $('#dialog_overlap').dialog('close');
            //     }
            //   });
            // },
            'Cancel' : function() {
              reRenderCurrentEvent();
              $(this).dialog('close');
            }
          }
        });
        dialogOverlap.dialog('open');
      }
    }
  });
}

function confirm_update_popup(){
  $('.overlay-bg').css({
    'height': $(document).height(),
    'display': 'block'
  });

  var dialog = $('#dialog-update-popup');
  var dialogW = $(dialog).width();
  var windowW = $(window).width();
  var xCordinate = (windowW - dialogW) / 2;
  dialog.css({'top': 44, 'left': xCordinate});
  showDialog('dialog-update-popup');
}

var current_event = function() {
  var event_id = localStorage.getItem('current_event_id');
  return $calendar.fullCalendar('clientEvents', [event_id])[0];
};

function reRenderCurrentEvent() {
  var _event = current_event();

  if (_event === undefined) return;

  _event.start = _event.start_time_before_drag;
  _event.end = _event.finish_time_before_drag;

  $calendar.fullCalendar('updateEvent', _event);
  $calendar.fullCalendar('renderEvent', _event, true);
}
