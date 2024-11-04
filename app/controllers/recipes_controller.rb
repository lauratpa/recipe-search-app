class RecipesController < ApplicationController
  def index
    recipes = Recipe.order("rating desc").limit(10).includes(:ingredients)

    or_recipes = recipes.any_ingredient_by_rating(filter.or) if filter.or.any?
    and_recipes = recipes.all_ingredients_by_rating(filter.and) if filter.and.any?

    recipes = or_recipes.or(and_recipes) if or_recipes && and_recipes
    recipes = and_recipes if and_recipes && !or_recipes
    recipes = or_recipes if or_recipes && !and_recipes

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
