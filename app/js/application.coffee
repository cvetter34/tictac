"use strict"

@ticTacToe = angular.module 'TicTacToe', []

ticTacToe.constant 'WIN_PATTERNS',
  [
    [0,1,2]
    [3,4,5]
    [6,7,8]
    [0,3,6]
    [1,4,7]
    [2,5,8]
    [0,4,8]
    [2,4,6]
  ]

class BoardCtrl
  constructor: (@$scope, @WIN_PATTERNS) ->
    @resetBoard()
    @$scope.mark = @mark
    @$scope.startGame = @startGame
    @$scope.gameOn = false
    @$scope.animateIt = @animateIt

  startGame: =>
    @$scope.gameOn = true
    @resetBoard()

  getPatterns: =>
    @patternsToTest = @WIN_PATTERNS #.filter -> true

  getRow: (pattern) =>
    "#{@cells[pattern[0]] || pattern[0]}" +
    "#{@cells[pattern[1]] || pattern[1]}" +
    "#{@cells[pattern[2]] || pattern[2]}"

  someoneWon: (row) ->
    'xxx' == row || 'ooo' == row

  resetBoard: =>
    @$scope.theWinnerIs = false
    @$scope.cats = false
    @cells = @$scope.cells = {}
    @winningCells = @$scope.winningCells = {}
    @$scope.currentPlayer = @player()
    @getPatterns()

  numberOfMoves: =>
    Object.keys(@cells).length

  movesRemaining: (player) =>
    totalMoves = 9 - @numberOfMoves()

    if player == 'x'
      Math.ceil(totalMoves / 2)
    else if player == 'o'
      Math.floor(totalMoves / 2)
    else
      totalMoves

  player: (options) =>
    options ||= whoMovedLast: false
    moves = @numberOfMoves() - (if options.whoMovedLast then 1 else 0)
    if moves % 2 == 0 then 'x' else 'o'

  isMixedRow: (row) ->
    row.match(/o+\d?x+|x+\d?o+/i)?

  hasOneX: (row) ->
    row.match(/x\d\d|\dx\d|\d\dx/i)?

  hasTwoXs: (row) ->
    row.match(/xx\d|x\dx|\dxx/i)?

  hasOneO: (row) ->
    row.match(/o\d\d|\do\d|\d\do/i)?

  hasTwoOs: (row) ->
    row.match(/oo\d|o\do|\doo/i)?

  isEmptyRow: (row) ->
    row.match(/\d\d\d/i)?

  gameUnwinnable: =>
    @patternsToTest.length < 1

  announceWinner: (winningPattern) =>
    winner = @cells[winningPattern[0]]
    for k, v of @cells
      @winningCells[k] = if parseInt(k) in winningPattern then 'win' else 'unwin'
    @$scope.theWinnerIs = winner
    @$scope.gameOn = false

  announceTie: =>
    @$scope.cats = true
    @$scope.gameOn = false

  rowStillWinnable: (row) =>
    not (@isMixedRow(row) or
    (@hasOneX(row) and @movesRemaining('x') < 2) or
    (@hasTwoXs(row) and @movesRemaining('x') < 1) or
    (@hasOneO(row) and @movesRemaining('o') < 2) or
    (@hasTwoOs(row) and @movesRemaining('o') < 1) or
    (@isEmptyRow(row) and @movesRemaining() < 5))

  getWinningCell: (row, player, winningMoves) ->
    o = /oo(\d)|o(\d)o|(\d)oo/i
    x = /xx(\d)|x(\d)x|(\d)xx/i
    m = row.match (if player == 'x' then x else o)
    if m?
      winningMoves.push m[1] || m[2] || m[3]

  getPossibleWins: (row, player, possibleWins) ->
    o = /o(\d)(\d)|(\d)o(\d)|(\d)(\d)o/i
    x = /x(\d)(\d)|(\d)x(\d)|(\d)(\d)x/i
    m = row.match (if player == 'x' then x else o)
    if m?
      for i in [1,2,3,4,5,6]
        if m[i]
          possibleWins[m[i]] ||= 0
          possibleWins[m[i]] += 1

  flashCells: (cells) =>
    color = if @player() == 'x'
      "hsla( 208, 55.9%, 44.5%, 0.7 )"
    else "hsla( 120, 39.6%, 46.0%, 0.7 )"

    for cell in cells
      jQuery("#cell-#{cell}").css backgroundColor: color
      jQuery("#cell-#{cell}").animate backgroundColor: "white", 2000

  hintAtBestMoves: () =>
    winOnThisMove = []
    blockLoss = []
    forceWinInTwo = {}
    blockWinInTwo = {}

    for pattern in @patternsToTest
      row = @getRow(pattern)
      @getWinningCell(row, @player(), winOnThisMove)
      @getWinningCell(row, @player(whoMovedLast: true), blockLoss)
      @getPossibleWins(row, @player(), forceWinInTwo)
      @getPossibleWins(row, @player(whoMovedLast: true), blockWinInTwo)

    forceWinInTwo = Object.keys(forceWinInTwo).filter (k) -> forceWinInTwo[k] > 1
    blockWinInTwo = Object.keys(blockWinInTwo).filter (k) -> blockWinInTwo[k] > 1

    @flashCells if winOnThisMove.length > 0
      winOnThisMove
    else if blockLoss > 0
      blockLoss
    else if forceWinInTwo.length > 0
      forceWinInTwo
    else if blockWinInTwo.length > 0
      blockWinInTwo
    else []

  parseBoard: =>
    winningPattern = false

    @patternsToTest = @patternsToTest.filter (pattern) =>
      row = @getRow(pattern)
      winningPattern ||= pattern if @someoneWon(row)
      @rowStillWinnable(row)

    if winningPattern
      @announceWinner(winningPattern)
    else if @gameUnwinnable()
      @announceTie()
    else
      @hintAtBestMoves()

  mark: (@$event) =>
    cell = @$event.target.dataset.index
    if @$scope.gameOn && !@cells[cell]
      @cells[cell] = @player()
      @parseBoard()
      @$scope.currentPlayer = @player()


BoardCtrl.$inject = ["$scope", "WIN_PATTERNS"]
ticTacToe.controller "BoardCtrl", BoardCtrl