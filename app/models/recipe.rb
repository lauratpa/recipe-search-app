class Recipe < ApplicationRecord
  belongs_to :category
  has_many :recipe_ingredients, dependent: :delete_all
  has_many :ingredients, through: :recipe_ingredients

  scope :by_rating, -> { order(rating: :desc) }
  scope :with_ingredients, ->(ingredient_ids) {
    joins(:recipe_ingredients).where(recipe_ingredients: { ingredient_id: ingredient_ids })
  }

  # Returns recipes with at least one matching ingredient sorted by match count and rating
  def self.or_ingredients_by_rating(ingredient_ids)
    select("recipes.*, count(ingredient_id) as ingredient_count")
      .with_ingredients(ingredient_ids)
      .group("recipes.id")
      .order("ingredient_count desc, rating desc")
  end

  # Returns recipes with all matching ingredients sorted by rating
  def self.and_ingredients_by_rating(ingredient_ids)
    select("recipes.*, count(ingredient_id) as ingredient_count")
      .with_ingredients(ingredient_ids)
      .group("recipes.id")
      .having("count(ingredient_id) = ?", ingredient_ids.size)
      .by_rating
  end

  # Returns recipes which don't contain the given ingredients sorted by rating
  def self.not_ingredients_by_rating(ingredient_ids)
    sub_select = select("id")
      .with_ingredients(ingredient_ids)
      .group("recipes.id")
      .having("count(ingredient_id) > 0")

    where.not("id IN (#{sub_select.to_sql})").by_rating
  end

  # Returns recipes which don't contain the given ingredients but contain optional ingredients
  def self.not_or_ingredients_by_rating(not_ingredient_ids:, or_ingredient_ids:)
    sub_select = select("id")
      .with_ingredients(not_ingredient_ids)
      .group("recipes.id")
      .having("count(ingredient_id) > 0")

    select("recipes.*, count(ingredient_id) as ingredient_count")
      .with_ingredients(or_ingredient_ids)
      .group("recipes.id")
      .where.not("recipes.id IN (#{sub_select.to_sql})")
      .order("ingredient_count desc, rating desc")
  end

  # Returns recipes with all matching ingredients but optional ingredients are included
  # in the match count
  def self.and_or_ingredients_by_rating(and_ingredient_ids:, or_ingredient_ids:)
    sub_select = select("id")
      .with_ingredients(and_ingredient_ids)
      .group("recipes.id")
      .having("count(ingredient_id) = ?", and_ingredient_ids.size)

    select("recipes.*, count(ingredient_id) as ingredient_count")
      .where("recipes.id IN (#{sub_select.to_sql})")
      .with_ingredients(and_ingredient_ids + or_ingredient_ids)
      .group("recipes.id")
      .order("ingredient_count desc, rating desc")
  end

  def self.and_not_or_ingredients_by_rating(and_ingredient_ids:, not_ingredient_ids:, or_ingredient_ids:)
    not_ids_sub_select = select("id")
      .with_ingredients(not_ingredient_ids)
      .group("recipes.id")
      .having("count(ingredient_id) > 0")

    and_ids_sub_select = select("id")
      .with_ingredients(and_ingredient_ids)
      .group("recipes.id")
      .having("count(ingredient_id) = ?", and_ingredient_ids.size)

    select("recipes.*, count(ingredient_id) as ingredient_count")
      .where("recipes.id IN (#{and_ids_sub_select.to_sql})")
      .where.not("recipes.id IN (#{not_ids_sub_select.to_sql})")
      .with_ingredients(and_ingredient_ids + or_ingredient_ids)
      .group("recipes.id")
      .order("ingredient_count desc, rating desc")
  end
end
