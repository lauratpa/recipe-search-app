class RecipesController < ApplicationController
  def index
    recipes = default_recipes
    recipes = or_recipes if filter.only_or?
    recipes = and_recipes if filter.only_and?
    recipes = and_or_recipes if filter.and_or?
    recipes = not_recipes if filter.only_not?
    recipes = not_or_recipes if filter.or_not?
    recipes = and_not_recipes if filter.and_not?
    recipes = and_not_or_recipes if filter.all?

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
      .where.not(id: filter.not)
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

  def not_recipes
    Recipe.not_ingredients_by_rating(filter.not)
  end

  def and_or_recipes
    Recipe.and_or_ingredients_by_rating(and_ingredient_ids: filter.and, or_ingredient_ids: filter.or)
  end

  def not_or_recipes
    Recipe.not_or_ingredients_by_rating(or_ingredient_ids: filter.or, not_ingredient_ids: filter.not)
  end

  def and_not_recipes
    Recipe.and_not_ingredients_by_rating(and_ingredient_ids: filter.and, not_ingredient_ids: filter.not)
  end

  def and_not_or_recipes
    Recipe.and_not_or_ingredients_by_rating(
      and_ingredient_ids: filter.and,
      not_ingredient_ids: filter.not,
      or_ingredient_ids: filter.or
    )
  end
end
