class RecipesController < ApplicationController
  def index
    recipes = Recipe.by_ingredient_and_rating(params[:ingredient_ids]).limit(10)
    recipes = Recipe.order("rating desc").limit(10) if params[:ingredient_ids].blank?

    ingredients = Ingredient.order_by_recipe_count.limit(50)

    render :index, locals: { recipes: recipes, ingredients: ingredients }
  end

  def show
    recipe = Recipe.includes(:ingredients).find(params[:id])

    render :show, locals: { recipe: recipe }
  end
end
