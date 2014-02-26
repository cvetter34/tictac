$ ->
  counter = 0

  WIN_PATTERNS = [
    [0,1,2]
    [3,4,5]
    [6,7,8]
    [0,3,6]
    [1,4,7]
    [2,5,8]
    [0,4,8]
    [2,4,6]
  ]

  mixed = /x+o+|o+x+/i

  patternsToTest = WIN_PATTERNS.filter -> true

  isEmpty = (cell) ->
    !cell.text()

  getCellNumber = (cell) ->
    parseInt cell.data('index')

  clearBoard = ->
    $('.board-cell').text('')
    $('.board-cell').removeClass('o')
    $('.board-cell').removeClass('x')
    patternsToTest = WIN_PATTERNS.filter -> true
    counter = 0

  resetGame = ->
    clearBoard()
    $('#gameboard').hide()
    $('#start-game').fadeIn(500)

  oTurnsRemaining = ->
    Math.floor(( 9 - counter ) / 2)
  xTurnsRemaining = ->
    oTurnsRemaining() + ( 9 - counter ) % 2

  rowUnwinnable = (row) ->
    !!row.match(mixed) ||
    (row == 'x' && (xTurnsRemaining() < 2)) ||
    (row == 'xx' && (xTurnsRemaining() < 1)) ||
    (row == 'o' && (oTurnsRemaining() < 2)) ||
    (row == 'oo' && (oTurnsRemaining() < 1)) ||
    (row == '' && (9 - counter < 5))

  checkForWin = (cell) ->
    win = false
    board = ( $('.board-cell').map (idx, el) -> $(el).text() ).get()

    patternsToTest = patternsToTest.filter (p) ->
      row = "#{board[p[0]]}#{board[p[1]]}#{board[p[2]]}"
      win ||= (row == 'xxx' || row == 'ooo')
      not rowUnwinnable(row)

    if win
      alert getTurn(counter - 1) + ' won!'
      resetGame()
    else if patternsToTest.length < 1
      alert 'Tie game!'
      resetGame()

  getTurn = (c) -> if c % 2 == 0 then 'x' else 'o'

  markCell = (cell, mark) ->
    cell.text mark
    cell.addClass mark
    counter += 1
    checkForWin( getCellNumber(cell) ) if counter > 4

  # Start the game
  $('#start-game').on 'click', (e) ->
    clearBoard()
    $(@).hide()
    $('#gameboard').fadeIn(500)

  # Make a move
  $('.board-cell').on 'click', (e) ->
    cell = $(@)
    mark = getTurn(counter)
    markCell(cell, mark) if isEmpty(cell)