class Recipe < ApplicationRecord
  belongs_to :category
  has_many :recipe_ingredients, dependent: :delete_all
  has_many :ingredients, through: :recipe_ingredients
end
