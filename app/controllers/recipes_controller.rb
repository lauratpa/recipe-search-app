class RecipesController < ApplicationController
  def index
    recipes = Recipe.by_ingredient_and_rating(filter.or).limit(10)
    recipes = Recipe.order("rating desc").limit(10) if filter.none?

    ingredients = Ingredient.order_by_recipe_count.limit(50)

    render :index, locals: { recipes: recipes, ingredients: ingredients, filter: filter }
  end

  def show
    recipe = Recipe.includes(:ingredients).find(params[:id])

    render :show, locals: { recipe: recipe }
  end

  private

  def filter
    @filter ||= RecipeFilter.new(params)
  end
end
