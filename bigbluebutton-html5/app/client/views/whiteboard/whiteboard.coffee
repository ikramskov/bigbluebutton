# scale the whiteboard to adapt to the resized window
@scaleWhiteboard = (callback) ->
  adjustedDimensions = scaleSlide(getInSession('slideOriginalWidth'), getInSession('slideOriginalHeight'))
  wpm = whiteboardPaperModel
  wpm.scale(adjustedDimensions.width, adjustedDimensions.height)
  if callback
    callback()

Template.whiteboard.helpers
  presentationProgress: ->
    currentPresentation = Meteor.Presentations.findOne({'presentation.current':true})
    currentSlideNum = Meteor.Slides.findOne({'presentationId': currentPresentation?.presentation.id, 'slide.current':true})?.slide.num
    totalSlideNum = Meteor.Slides.find({'presentationId': currentPresentation?.presentation.id})?.count()
    if currentSlideNum isnt undefined
      return "#{currentSlideNum}/#{totalSlideNum}"
    else
      return ''
  isPollStarted: ->
    if BBB.isPollGoing(getInSession('userId'))
      return true
    else
      return false

Template.whiteboard.events
  'click .whiteboardFullscreenButton': (event, template) ->
    enterWhiteboardFullscreen()

  'click .exitFullscreenButton': (event, template) ->
    if document.exitFullscreen
      document.exitFullscreen()
    else if document.mozCancelFullScreen
      document.mozCancelFullScreen()
    else if document.webkitExitFullscreen
      document.webkitExitFullscreen()

  'click .raiseHand': (event) ->
    BBB.raiseHand(BBB.getMeetingId(), getInSession('userId'), getInSession('userId'), getInSession('authToken'))

  'click .lowerHand': (event) ->
    BBB.lowerHand(BBB.getMeetingId(), getInSession('userId'), getInSession('userId'), getInSession('authToken'))

Template.presenterBottomControllers.events
  'click .previousSlide':(event) ->
    console.log "previous"
    BBB.goToPreviousPage()

  'click .nextSlide':(event) ->
    console.log "next"
    BBB.goToNextPage()

  'click .switchSlideButton': (event) ->
    $('.tooltip').hide()

Template.polling.events
  'click .pollButtons': (event) ->
    _key = @.label
    _id = @.answer
    BBB.sendPollResponseMessage(_key, _id)

Template.polling.rendered = ->
  scaleWhiteboard()

Template.polling.destroyed = ->
  setTimeout(scaleWhiteboard, 0)

Template.presenterBottomControllers.rendered = ->
  scaleWhiteboard()

Template.presenterBottomControllers.destroyed = ->
  setTimeout(scaleWhiteboard, 0)

Template.whiteboard.rendered = ->
  $('#whiteboard').resizable
    handles: 'e'
    minWidth: 150
    resize: () ->
      adjustChatInputHeight()
    start: () ->
      if $('#chat').width() / $('#panels').width() > 0.2 # chat shrinking can't make it smaller than one fifth of the whiteboard-chat area
        $('#whiteboard').resizable('option', 'maxWidth', $('#panels').width() - 200) # gives the chat enough space (200px)
      else
        $('#whiteboard').resizable('option', 'maxWidth', $('#whiteboard').width())
    stop: () ->
      $('#whiteboard').css('width', 100 * $('#whiteboard').width() / $('#panels').width() + '%') # transforms width to %
      $('#whiteboard').resizable('option', 'maxWidth', null)
