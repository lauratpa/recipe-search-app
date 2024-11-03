class RecipesController < ApplicationController
  def index
    recipes = Recipe.with_ingredients(params[:ingredient_ids]).by_rating.limit(10)
    recipes = Recipe.order("rating desc").limit(10) if params[:ingredient_ids].blank?

    ingredients = Ingredient.order_by_recipe_count.limit(50)

    render :index, locals: { recipes: recipes, ingredients: ingredients }
  end
end
