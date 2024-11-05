class RecipesController < ApplicationController
  def index
    recipes = FilterRecipes.call(filter)
    total_recipes_count = Recipe.from(recipes).count

    recipes = recipes.limit(limit).offset(offset).includes(:ingredients)

    render(
      :index,
      locals: {
        recipes: recipes,
        ingredients: default_ingredients,
        filter: filter,
        total_recipes_count: total_recipes_count,
        next_page: page + 1,
        limit: limit
      }
    )
  end

  def show
    recipe = Recipe.find(params[:id])

    render :show, locals: {recipe: recipe}
  end

  private

  def filter
    @filter ||= RecipeFilter.new(params)
  end

  def limit
    (params[:limit] || 10).to_i
  end

  def page
    (params[:page] || 1).to_i
  end

  def offset
    (page - 1) * limit
  end

  def default_ingredients
    Ingredient.filtered(filter).order_by_recipe_count.limit(50)
  end
end
