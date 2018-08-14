// app/assets/javascripts/application.js
//= require jquery
//= require jquery_ujs
$( document ).ready(function() {
    $("#add-user-trip").click(function () {
        var user_id  = $(".select-user").val()
        var trip_id = $(this).data('trip-id')
        if(user_id){
            $.ajax({
                url: '/admin/trips/' + trip_id + "/add_user/" + user_id,
                data: 'json',
                error: function() {
                    $('#info').html('<p>An error has occurred</p>');
                },
                dataType: 'html',
                success: function(data) {
                    $("#tb-user-trip").append(data)
                    console.log(data)
                },
                type: 'PUT'
            });
        }

    })
});