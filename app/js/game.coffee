$ ->
  isX = true

  clearBoard = ->
    $('.board-cell').text('')
    isX = true

  $('#start-game').on 'click', (e) ->
    clearboard()
    $(@).hide()
    $('#gameboard').fadeIn(500)

  $('.board-cell').on 'click', (e) ->
    mark = if isX then 'x' else 'o'
    if ( $(@).text().replace /^\s+|\s+$/g, "" ) == ''
      $(@).text mark
      $(@).addClass mark
      isx = !isX