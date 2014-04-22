class Serncookity.Views.Unturd extends Backbone.View

  template: JST['home/index']
  steps_template: JST['home/steps']
  ingredients_template: JST['home/ingredients']

  recipe_url: "https://api.pearson.com/kitchen-manager/v1/recipes"
  recipes: []
  new_recipe: {
    steps: []
    ingredients: []
    ingredient_names: []
    name: ""
  }

  # Define main element to attach to
  el: "#container"
  
  initialize: ->
    @go_get_em()
    @render()

  render: ->
    @$el.html(@template())

  render_recipe: ->
    $("#steps_container").html(@steps_template(steps: @new_recipe['steps']))
    $("#ingredients_container").html(@ingredients_template(ingredients: @new_recipe['ingredients']))
    $("#recipe_title").html(@new_recipe['name'])

  go_get_em: ->
    $.getJSON @recipe_url, (result) =>
      @total_recipes = result['total']
      @get_some()

  get_some: ->
    @steps = @rand_int 1, 5
    for step in [1..@steps]
      $.getJSON @recipe_url, {limit: 1, offset: @rand_int(0, @total_recipes-1)}, (result) =>
        $.getJSON result['results'][0]['url'], {contentType: "application/json; charset=utf-8"}, (recipe_result) =>
          @recipes.push recipe_result
          @mashup() if @recipes.length == @steps

  mashup: ->
    @recipes.sort (a,b) ->
      return 1 if a.directions.length > b.directions.length
      return -1 if a.directions.length < b.directions.length
      return 0

    served = false
    end_regex = new RegExp(/serve/ig)

    for recipe, i in @recipes
      # Get the target sentence      
      target = if recipe['directions'].length > i then recipe['directions'][i] else recipe['directions'][recipe['directions'].length-1]
      target = target.toLowerCase()
      target = target.replace(/^([0-9]|\s)*/,"")
      target = target.substring(0,target.indexOf("."))
      
      title_array = recipe['name'].split(" ")
      @new_recipe['name'] += (if title_array.length > i then title_array[i] else title_array[title_array.length-1]) + " "

      @new_recipe['steps'].push target

      target_stemmed = (stemmer(t.replace(/[,]/g,"")) for t in target.split(" "))

      for ingredient in recipe['ingredients']
        found_ingredient = false

        if stemmer(ingredient['name'].toLowerCase()) in target_stemmed
          found_ingredient = true
        else if "ingredients" in target and Math.random() > 0.7 # If it says something like 'all ingredients, pick some randomly' 
          found_ingredient = true
        else
          for t in ingredient['name'].toLowerCase().split " "
            console.log t, target_stemmed
            if stemmer(t) in target_stemmed or t in target
              found_ingredient = true
              break

        if (ingredient['name'].toLowerCase() not in @new_recipe['ingredient_names']) and found_ingredient
          @new_recipe['ingredients'].push ingredient
          @new_recipe['ingredient_names'].push ingredient['name'].toLowerCase()
      
      if end_regex.test(target)
        served = true
        break

    # Optimize!
    unless served
      servable = ["serve on a platter.", "serve in a bowl.", "serve warm.", "garnish and serve."]
      @new_recipe['steps'].push servable[@rand_int(0,servable.length-1)]

    @render_recipe()

  rand_int: (min, max) ->
    Math.floor(Math.random() * (max - min + 1)) + min