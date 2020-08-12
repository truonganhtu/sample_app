$(function () {
  $('#micropost_image').change(function () {
    let size_in_megabytes = this.files[0].size / 1024 / 1024;
    if (size_in_megabytes > 5) {
      alert(I18n.t("microposts.errors.size_too_big"));
    }
  });
});
