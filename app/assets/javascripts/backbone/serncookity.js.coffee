#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

window.Serncookity =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}

  init: ->
    console.log 'cook!'
    @Routers.MainRouter = new Serncookity.Routers.Main()
    Backbone.history.start({pushState: true, hashChange: false})

$(document).ready ->
  Serncookity.init() unless Backbone.History.started
  