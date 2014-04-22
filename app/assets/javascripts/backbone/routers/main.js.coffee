class Serncookity.Routers.Main extends Backbone.Router

  routes:
    '': 'home'

  home: ->
    console.log 'kaka'
    new Serncookity.Views.Unturd()
