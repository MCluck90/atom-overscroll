{CompositeDisposable} = require 'atom'

module.exports = Overscroll =
  config:
    numOfLines:
      title: 'Number of Lines'
      description: 'Number of extra lines to show at the bottom'
      type: 'integer'
      default: 50
    percent:
      title: 'Relative Percent'
      description: 'If set, will adjust size based on size of editor'
      type: 'number'
      default: 0

  activate: (state) ->
    @cd = new CompositeDisposable

    @cd.add atom.workspace.observeTextEditors (editor) =>
      return if editor.mini

      editor.displayBuffer.getScrollHeight = ->
        lineHeight = @getLineHeightInPixels()
        return 0 unless lineHeight > 0

        percent = atom.config.get('overscroll.percent')
        if percent
          return @getHeight() * percent

        scrollHeight = (atom.config.get('overscroll.numOfLines') + @getLineCount()) * lineHeight
        if @height? and @configSettings.scrollPastEnd
          scrollHeight = scrollHeight + @height - (lineHeight * 3)

        scrollHeight

      editor.displayBuffer.getVisibleRowRange = ->
        return [0, 0] unless @getLineHeightInPixels() > 0

        heightInLines = Math.ceil(@getHeight() / @getLineHeightInPixels()) + 1
        startRow = Math.min(@getLineCount(), Math.floor(@getScrollTop() / @getLineHeightInPixels()))
        endRow = Math.min(@getLineCount(), startRow + heightInLines)

        [startRow, endRow]


  deactivate: ->
    @cd.dispose()
