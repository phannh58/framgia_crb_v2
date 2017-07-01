$(document).ready(function(){
  var timeout;
  var searchUser = $('#search-user');
  var result = $('#result');

  searchUser.on('input', function(){
    result.html('');

    if (searchUser.val()) {
      clearTimeout(timeout);
      timeout = setTimeout(function(){ search_user() }, 500);
    }
  });

  function search_user(){
    var q = searchUser.val();
    var org_slug = $('#organ_slug').val();
    searchUser.addClass('loading');

    $.ajax({
      url: '/users/search',
      type: 'get',
      dateType: 'text',
      data: {q: q, org_slug: org_slug},
      success: function(data){
        result.html(data);
        result.find('a').hover(function(){
          $('.name-list').blur();
          $(this).focus();
        });
      },
      complete: function() {
        searchUser.removeClass('loading');
      }
    });
  }

  $(document).keydown(function(e){
    if (e.keyCode == 40){
      if ($('.name-list:focus').length > 0) {
        $('.name-list:focus').closest('li').next().find('a.name-list').focus();
      } else {
        $('.name-list').eq(0).focus();
      }
    }

    if (e.keyCode == 38){
      if ($('.name-list:focus').length > 0){
        $('.name-list:focus').closest('li').prev().find('a.name-list').focus();
      } else {
        $('.name-list').last().focus();
      }
    }
  });

  $('#invite-modal').on('hidden.bs.modal', function() {
    result.empty();
    searchUser.val('');
  });

  $('#invitation-tabs a').click(function (e) {
    document.location.href = $(this).attr('href');
  })
});
