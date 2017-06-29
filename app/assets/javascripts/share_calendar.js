'use strict';

$(document).ready(function(){
  var makePublicCheckBox = $('#make_public');
  var freeBusyCheckBox = $('#free_busy');

  if (makePublicCheckBox.val() === 'public_hide_detail') {
    makePublicCheckBox.prop('checked', true);
    freeBusyCheckBox.prop('checked', true);
  } else if (makePublicCheckBox.val() === 'share_public') {
    makePublicCheckBox.prop('checked', true);
  } else if (makePublicCheckBox.val() === 'no_public') {
    makePublicCheckBox.prop('checked', false);
    freeBusyCheckBox.prop('disabled', true);
  }

  makePublicCheckBox.click(function() {
    $(this).val(this.checked ? 'share_public' : 'no_public');
    freeBusyCheckBox.prop('disabled', !this.checked);
  });

  freeBusyCheckBox.click(function() {
    makePublicCheckBox.val(freeBusyCheckBox.prop('checked') ? 'public_hide_detail' : 'share_public');
  });

  /* share-calendar*/

  $('#textbox-email-share').select2({
    tokenSeparators: [',', ' '],
    width: '100%'
  });

  var current_user = $('#current_user').val();
  var user_ids = [current_user];

  $('.user_share_ids').each(function() {
    var user_id_temp = $(this).val();

    if ($.inArray(user_id_temp, user_ids) == -1) {
      user_ids.push(user_id_temp);
    }
  });

  $('#add-person').on('click', function() {
    var user_id = $('#textbox-email-share').val();
    var email = $('#textbox-email-share').find('option:selected').text();
    var permission = $('#permission-select').val();
    var color_id = $('#calendar_color_id').val();

    if (user_id) {
      $.ajax({
        url: '/share_calendars/new',
        method: 'get',
        data: {
          user_id: user_id,
          email: email,
          permission: permission,
          color_id: color_id
        },
        success: function(html) {
          if ($.inArray(user_id, user_ids) === -1) {
            if($('#user-calendar-share-' + user_id).length > 0) {
              $('#user-calendar-share-' + user_id).css('display', 'block');
              $('#user-calendar-share-' + user_id).find('.user_calendar_destroy').val(false);
              $('#user-calendar-share-' + user_id).find('.permission-select').val($('#permission-select').val());
            } else {
              $('#list-share-calendar').append(html);
              $('#user-calendar-share-' + user_id).find('.permission-select').select2({
                tags: true,
                minimumResultsForSearch: Infinity
              });
              user_ids.push(user_id);
            }
          }
        }
      });
    }
    $('#textbox-email-share').val('');
    $('#select2-textbox-email-share-container').html('');
  });

  $('#list-share-calendar').on('click', '.image-remove', function() {
    $(this).parent().parent().find('.user_calendar_destroy').val('1');
    $(this).parent().parent().hide();
    var index = user_ids.indexOf($(this).prop('id'));

    if (index !== -1) user_ids.splice(index, 1);
  });
})
