function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id));
}

$(document).ajaxError(function (e, xhr, settings) {
        if (xhr.status == 401) {
           $('#error_explanation').html(xhr.responseText);
        }
        else {
           $('#modal_error_explanation').html("<h5>Please sign in or sign up to continue</h5>");
        }
    });

$("#pubmed_results_<%= @point_id %>").html("<%= escape_javascript(render 'researches/view_result') %>")