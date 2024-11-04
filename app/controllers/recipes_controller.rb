class RecipesController < ApplicationController
  def index
    recipes = Recipe.order("rating desc")

    or_recipes = recipes.any_ingredient_by_rating(filter.or) if filter.or.any?
    and_recipes = recipes.all_ingredients_by_rating(filter.and) if filter.and.any?

    recipes = or_recipes.or(and_recipes) if or_recipes && and_recipes
    recipes = and_recipes if and_recipes && !or_recipes
    recipes = or_recipes if or_recipes && !and_recipes

    total_recipes_count = Recipe.from(recipes).count

    recipes = recipes.limit(limit).offset(offset).includes(:ingredients)

    ingredients = Ingredient.order_by_recipe_count.limit(50)

    render(
      :index,
      locals: {
        recipes: recipes,
        ingredients: ingredients,
        filter: filter,
        total_recipes_count: total_recipes_count,
        next_page: page + 1,
        limit: limit
      }
    )
  end

  def show
    recipe = Recipe.includes(:ingredients).find(params[:id])

    render :show, locals: { recipe: recipe }
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
end
