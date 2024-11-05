class FilterRecipes
  def initialize(filter)
    @filter = filter
  end

  def self.call(filter)
    new(filter).call
  end

  def call
    return or_recipes if filter.only_or?
    return and_recipes if filter.only_and?
    return and_or_recipes if filter.and_or?
    return not_recipes if filter.only_not?
    return not_or_recipes if filter.or_not?
    return and_not_recipes if filter.and_not?
    return and_not_or_recipes if filter.all?

    default_recipes
  end

  private

  attr_reader :filter

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
