class Recipe < ApplicationRecord
  belongs_to :category
  has_many :recipe_ingredients, dependent: :delete_all
  has_many :ingredients, through: :recipe_ingredients

  scope :by_rating, -> { order(rating: :desc) }
  scope :with_ingredients, ->(ingredient_ids) {
    joins(:recipe_ingredients).where(recipe_ingredients: { ingredient_id: ingredient_ids })
  }
  scope :by_ingredient_and_rating, ->(ingredient_ids) {
    select("recipes.*, count(ingredient_id) as ingredient_count")
      .with_ingredients(ingredient_ids)
      .group("recipes.id")
      .order("ingredient_count desc, rating desc")
  }
end
