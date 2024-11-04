class RecipesController < ApplicationController
  def index
    recipes = default_recipes
    recipes = or_recipes if filter.only_or?
    recipes = and_recipes if filter.only_and?
    recipes = and_or_recipes if filter.and_or?

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

  def default_ingredients
    Ingredient
      .where.not(id: filter.and)
      .where.not(id: filter.or)
      .order_by_recipe_count
      .limit(50)
  end

  def default_recipes
    Recipe.by_rating
  end

  def or_recipes
    Recipe.or_ingredients_by_rating(filter.or)
  end

  def and_recipes
    Recipe.and_ingredients_by_rating(filter.and)
  end

  def and_or_recipes
    Recipe.and_or_ingredients_by_rating(and_ingredient_ids: filter.and, or_ingredient_ids: filter.or)
  end
end
