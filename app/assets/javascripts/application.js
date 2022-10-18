// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require jquery-ui
//= require rails-ujs
//= require popper
//= require bootstrap-sprockets
//= require activestorage
//= require js.cookie
//= require datetimepicker
//= require jquery-ui-month-picker
//= require pagy
//= require cocoon
//= require turbolinks
//= require_tree .

$(document).on("turbolinks:load", function() {
  $(".sidebar-toggle").click(function() {
    if (Cookies.get("isShrink") !== "true") {
      $(".sidebar").addClass("shrink");
      Cookies.set("isShrink", "true", { expires: 1 });
    } else {
      $(".sidebar").removeClass("shrink");
      Cookies.set("isShrink", "false", { expires: 1 });
    }
  });
});
