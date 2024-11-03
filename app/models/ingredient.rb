class Ingredient < ApplicationRecord
  has_many :recipe_ingredients, dependent: :delete_all
  has_many :recipes, through: :recipe_ingredients

  scope :search_by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }
  scope :order_by_recipe_count, -> {
    select("ingredients.id, name, count(recipe_id) as recipe_count")
      .joins(:recipe_ingredients)
      .group("ingredients.id")
      .order("recipe_count desc")
  }
end
