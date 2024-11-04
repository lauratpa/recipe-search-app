class Recipe < ApplicationRecord
  belongs_to :category
  has_many :recipe_ingredients, dependent: :delete_all
  has_many :ingredients, through: :recipe_ingredients

  scope :by_rating, -> { order(rating: :desc) }
  scope :with_ingredients, ->(ingredient_ids) {
    joins(:recipe_ingredients).where(recipe_ingredients: { ingredient_id: ingredient_ids })
  }
  scope :any_ingredient_by_rating, ->(ingredient_ids) {
    select("recipes.*, count(ingredient_id) as ingredient_count")
      .with_ingredients(ingredient_ids)
      .group("recipes.id")
      .order("ingredient_count desc, rating desc")
  }
  scope :all_ingredients_by_rating, ->(ingredient_ids) {
    recipe_ids = ingredient_ids
      .map { |i_id| RecipeIngredient.where(ingredient_id: i_id).pluck(:recipe_id) }
      .reduce(&:intersection)

    select("recipes.*, count(ingredient_id) as ingredient_count")
      .with_ingredients(ingredient_ids)
      .where(id: recipe_ids)
      .group("recipes.id")
      .order("ingredient_count desc, rating desc")
  }
end
