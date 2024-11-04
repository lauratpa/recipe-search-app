require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe '.with_ingredients' do
    it 'returns recipe which contain the given ingredient ids' do
      category = create(:category)
      bananas = create(:ingredient, name: 'bananas')
      apples = create(:ingredient, name: 'apples')

      create(:recipe, category: category).tap { |recipe| recipe.ingredients << bananas }
      apples_recipe = create(:recipe, category: category)
        .tap { |recipe| recipe.ingredients << apples }

      expect(described_class.with_ingredients([ apples.id ])).to contain_exactly(apples_recipe)
    end
  end

  describe '.any_ingredient_by_rating' do
    it 'orders recipes by rating' do
      category = create(:category)

      bananas = create(:ingredient, name: 'bananas')
      apples = create(:ingredient, name: 'apples')
      oranges = create(:ingredient, name: 'orange')

      second_recipe = create(:recipe, category: category, rating: 3.9)
        .tap { |recipe| recipe.ingredients << [ bananas, apples, oranges ] }
      first_recipe = create(:recipe, category: category, rating: 4.0)
        .tap { |recipe| recipe.ingredients << [ bananas, apples, oranges ] }
      third_recipe =create(:recipe, category: category, rating: 4.1)
        .tap { |recipe| recipe.ingredients << [ apples, oranges ] }
      fourth_recipe = create(:recipe, category: category, rating: 4.2)
        .tap { |recipe| recipe.ingredients << oranges }

      expect(described_class.any_ingredient_by_rating([ bananas.id, apples.id, oranges.id ]))
        .to eq([ first_recipe, second_recipe, third_recipe, fourth_recipe ])
    end
  end

  describe '.all_ingredients_by_rating' do
    it 'orders recipes by rating' do
      category = create(:category)

      bananas = create(:ingredient, name: 'bananas')
      apples = create(:ingredient, name: 'apples')
      oranges = create(:ingredient, name: 'orange')

      second_recipe = create(:recipe, category: category, rating: 3.9)
        .tap { |recipe| recipe.ingredients << [ bananas, apples, oranges ] }
      first_recipe = create(:recipe, category: category, rating: 4.0)
        .tap { |recipe| recipe.ingredients << [ bananas, apples ] }
      third_recipe = create(:recipe, category: category, rating: 4.1)
        .tap { |recipe| recipe.ingredients << [ bananas, oranges ] }
      fourth_recipe = create(:recipe, category: category, rating: 4.2)
        .tap { |recipe| recipe.ingredients << oranges }

      expect(described_class.all_ingredients_by_rating([ bananas.id, apples.id ]))
        .to eq([ first_recipe, second_recipe ])
    end
  end
end
