# Modifies user form
$(window).bind 'page:change', ->
  keyBlocker $('#user_username'), /(^[a-z0-9_\.]+$)/

  $ ->
    $('#users_index').DataTable
      'paging': false
      'lengthChange': false
      'searching': false
      'ordering': true
      'info': true
      'autoWidth': false
    return

  $file = $('#file_input')
  $file.change ->
    $('#display_input').val $(@).val().replace(/^.*[\\\/]/, '')
    return
  $('#select_btn').click ->
    $file.click()
    return

  $('#file_input').bind 'change', ->
    file = this.files[0]
    type = /(image)[\/](gif|jpe?g|png|bmp)$/;
    if file.size > 5000000
      toastr.warning I18n.profile_file_size
      this.value = null
      $('#display_input').val(null)
    else if !type.test file.type
      toastr.warning I18n.profile_file_type
      this.value = null
      $('#display_input').val(null)
      return
    return
  return
