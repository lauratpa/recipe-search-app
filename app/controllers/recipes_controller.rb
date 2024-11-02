class RecipesController < ApplicationController
  def index
    recipes = Recipe.first(10)
    ingredients = Ingredient.first(10)

    render :index, locals: { recipes: recipes, ingredients: ingredients }
  end
end
