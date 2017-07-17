$(document).on('ready', function() {
  $('.add-attendee').on('click', function() {
    var email = $('.attendee-email').val().trim();

    if (validateEmail(email) && !existEmail(email)){
      $('#list-attendee').append(attendeeTemplate(email));
      $('#group_attendee_name').removeAttr('disabled');
      $('.attendee-email').val('');
    } else {
      content = "Email is not valid or added to list"
      var dialogNotification = $('#dialog-notification');
      dialogNotification.html('<p clas="text-warning">' + content + '</p>');

      dialogNotification.dialog({
        autoOpen: false,
        modal: true,
        closeOnEscape: false,
        resizable: false,
        height: 'auto',
        width: 400,
        icon: 'ui-icon-alert',
        open: function(){
          dialogNotification.show();
        },
        buttons: {
          'OK' : function() {
            dialogNotification.hide();
            $(this).dialog('close');
          }
        }
      });

      dialogNotification.dialog('open');
    }
  });

  $('.attendee-email').autocomplete({
    source: '/search',
    response: function( event, ui ) {
      $.map(ui.content, function (item) {
        if (!existEmail(item.email)) return item;
      });
    }
  }).data('ui-autocomplete')._renderItem = function(ul, item) {
    return $('<li data-attendee-email="' + item.email + '">').append('<div class="ui-item"><i class="fa fa-user" aria-hidden="true"></i> <a data-user-id=' + item.user_id + '>' + item.email + '</a></div>').appendTo(ul);
  };

  $('input[type="checkbox"]#group_attendee_ids').change(function() {
    var emails = $(this).siblings().last().data('content');
    var array_email = $(emails).text().slice(0,-1).split(' ');
    if (this.checked) {
      for(i = 0; i < array_email.length; i++) {
        var attendee = attendeeTemplate(array_email[i]);
        if (!existEmail(array_email[i])) {
          $('#list-attendee').append(attendee);
          $('#group_attendee_name').removeAttr('disabled');
        }
      }
    } else {
      for(i = 0; i < array_email.length; i++) {
        var attendee = array_email[i];
        $("input[value='" + attendee + "']").parent().remove();
      }
      removeGroupAttendeeName();
    }
  });

  $(document).on('click', '.ui-menu-item', function(){
    var attendee = attendeeTemplate($(this).data('attendee-email'));
    $('#list-attendee').append(attendee);
    $('#group_attendee_name').removeAttr('disabled');
  });

  $('#list-attendee').on('click', '.remove-attendee', function(){
    $(this).parents('.attendee').remove();
    removeGroupAttendeeName();
  });

  function removeGroupAttendeeName() {
    if ($('#list-attendee').children().length == 0) {
      $('input[type="text"].group-attendee-name').val('');
      $('#group_attendee_name').attr('disabled','disabled')
                               .prop('checked', false);
      $('.name-group-attendee').addClass('hidden');
      $('input[type=checkbox]#group_attendee_ids').removeAttr('checked');
    }
  }

  function validateEmail(email) {
    var re = /^(([^<>()\[\]\\.,;:\s@']+(\.[^<>()\[\]\\.,;:\s@']+)*)|('.+'))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

    return !re.test(email.value);
  }

  function existEmail(email) {
    var attendeeEmails = $.map($('#list-attendee input'), function(item){return item.value.trim();});
    return $.inArray(email.trim(), attendeeEmails) != -1;
  }

  function attendeeTemplate(email) {
    return '<div class="attendee"> \
      <input type="hidden" name="attendee[emails][]" value="' + email + '" /> \
      <div class="row form-group"> \
        <div class="col-md-9"><i class="fa fa-user" aria-hidden="true"></i> ' + email + '</div> \
        <div class="col-md-3"> \
          <a href="javascript:void(0)" class="remove-attendee"> \
            <i class="fa fa-times" aria-hidden="true"></i> \
          </a> \
        </div> \
      </div> \
    </div>'
  }
});
