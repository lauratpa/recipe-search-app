class IngredientsController < ApplicationController
  def search
    ingredients = Ingredient
      .search_by_name(params[:search])
      .order_by_recipe_count
      .limit(50)

    render(
      partial: "ingredients/search_result",
      layout: false,
      locals: { ingredients: ingredients, filter: filter }
    )
  end

  private

  def filter
    @filter ||= RecipeFilter.new(params)
  end
end
