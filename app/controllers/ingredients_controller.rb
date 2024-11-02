class IngredientsController < ApplicationController
  def search
    ingredients = Ingredient.where("name ILIKE ?", "%#{params[:search]}%")

    render partial: "ingredients/search_result", layout: false, locals: { ingredients: ingredients }
  end
end
