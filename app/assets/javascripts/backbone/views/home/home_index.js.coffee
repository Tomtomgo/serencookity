class Serncookity.Views.Unturd extends Backbone.View

  template: JST['home/index']

  recipe_url: "https://api.pearson.com/kitchen-manager/v1/recipes"
  recipes: []
  new_recipe: {
    steps: []
    ingredients: []
  }

  # Define main element to attach to
  el: "#container"
  
  initialize: ->
    @render()
    @get_total()

  render: ->
    @$el.html(@template())

  get_total: ->
    $.getJSON @recipe_url, (result) =>
      @total_recipes = result['total']
      @get_some()

  get_some: ->
    @steps = @rand_int 1, 8
    for step in [1..@steps]
      $.getJSON @recipe_url, {limit: 1, offset: @rand_int(0, @total_recipes-1)}, (result) =>
        $.getJSON result['results'][0]['url'], (recipe_result) =>
          @recipes.push recipe_result
          @mashup() if @recipes.length == @steps

  mashup: ->
    @recipes.sort (a,b) ->
      return 1 if a.directions.length > b.directions.length
      return -1 if a.directions.length < b.directions.length
      return 0

    served = false
    end_regex = new RegExp(/serve/i)

    for recipe, i in @recipes
      
      target = if recipe['directions'].length > i then recipe['directions'][i] else recipe['directions'][recipe['directions'].length-1]
      @new_recipe['steps'].push target

      for ingredient in recipe['ingredients']
        @new_recipe['ingredients'].push ingredient if ingredient not in @new_recipe['ingredients']
      
      break if end_regex.test(target)

    # Optimize!
    unless served
      @new_recipe['steps'].push "Serve on a platter."

    console.log "done", @new_recipe

  render_recipe: ->
    $("#tittle").text 'New recipe'

  rand_int: (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min