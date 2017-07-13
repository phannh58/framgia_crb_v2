$(document).ready(function(){
  $('.logo-upload').change(function(){
    if (this.files && this.files[0]) {
      var reader = new FileReader();

      reader.onload = function (e) {
        $('.upload-image .logo-preview')
          .attr('src', e.target.result);
      };

      reader.readAsDataURL(this.files[0]);
    }
  });

  $('#organization-tabs a').click(function (e) {
    $(this).tab('show');
  });

  $('.nav-tabs a[href="' + window.location.hash + '"]').tab('show');

  $('#organization-tabs a').on('shown.bs.tab', function () {
    var url = $(this).attr('data-url');
    var tab = $(this).attr('data-tab');

    if (url) {
      $.ajax({
        url: url,
        method: 'get',
        success: function(result){
          $('#' + tab).html(result.content);
        },
        error: function(error){
          alert(error);
        }
      });
    }
  });

  $(document).delegate('.paginator.activities a', 'click', function(e){
    e.preventDefault();
    var url = $(this).attr('href');
    $.ajax({
      url: url,
      method: 'get',
      success: function(result){
        $('#activities').html(result.content);
      },
      error: function(error){
        alert(error);
      }
    });
  });
});
