#= require notify.js
#= require collections/activity_stream
#= require views/activity_view

SCROLL_TOLERANCE = 10

class window.ActivityStreamView extends Backbone.View
  collection: ActivityStream

  initialize: (options)->
    @unreadCount = 0
    @documentTitle = document.title

    @subviews = []

    @collection.each (model, index, collection) =>
      @buildSubviewForModel(model, index)

    @listenTo(@collection, 'add', @onCollectionAdd)
    $(window).on('focus', @onWindowFocus)

  render: ->
    view.render() for view in @subviews

  buildSubviewForModel: (model, index) ->
    view = new ActivityView(model: model)
    @subviews.splice(index, 0, view)

    if index == 0
      @$el.prepend(view.el)
    else
      @$(":nth-child(#{index-1})").after(view.el)

    view.render()

  setDocumentTitle: ->
    document.title = unreadDocumentTitle(@documentTitle, @unreadCount)

  incrementUnread: ->
    if !document.hasFocus()
      @unreadCount += 1
      @setDocumentTitle()

  scrollToLatestActivity: ->
    $(window).scrollTop($(document).height())

  # Event Handlers

  onCollectionAdd: (model, collection, info) =>
    lockScrollToBottom(=>
      @buildSubviewForModel(model, collection.indexOf(model))
    )
    @incrementUnread()

  onWindowFocus: =>
    @unreadCount = 0
    @setDocumentTitle()

# --

unreadDocumentTitle = (title, unread) ->
  if unread != 0
    "(#{unread}) #{title}"
  else
    title

lockScrollToBottom = (cb) ->
  scrolled = $(document).scrollTop()
  windowHeight = $(window).height()
  documentHeight = $(document).height()

  cb()

  if (scrolled + windowHeight) >= (documentHeight - SCROLL_TOLERANCE)
    $(document).scrollTop($(document).height())
