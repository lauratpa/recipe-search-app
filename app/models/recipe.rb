class Recipe < ApplicationRecord
  belongs_to :category
  has_many :recipe_ingredients, dependent: :delete_all
  has_many :ingredients, through: :recipe_ingredients

  scope :by_rating, -> { order(rating: :desc) }
  scope :with_ingredients, ->(ingredient_ids) {
    joins(:recipe_ingredients).where(recipe_ingredients: { ingredient_id: ingredient_ids })
  }
  # Returns recipes with at least one match sorted according to number of matching ingredients and rating
  def self.any_ingredient_by_rating(ingredient_ids)
    sub_select = select("recipes.*, count(ingredient_id) as ingredient_count")
      .with_ingredients(ingredient_ids)
      .group("recipes.id")
      .order("ingredient_count desc, rating desc")
  end
  # Returns recipes with all matches ingredient_ids sorted by rating
  def self.all_ingredients_by_rating(ingredient_ids)
    select("recipes.*, count(ingredient_id) as ingredient_count")
      .with_ingredients(ingredient_ids)
      .group("recipes.id")
      .having("count(ingredient_id) = ?", ingredient_ids.size)
      .by_rating
  end

  # Returns recipes with all matches but with counts also optional ingredient_ids
  def self.all_and_any_ingredients_by_rating(and_ingredient_ids, or_ingredient_ids)
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
end
