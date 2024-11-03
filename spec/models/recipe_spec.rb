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

      expect(Recipe.with_ingredients([ apples.id ])).to contain_exactly(apples_recipe)
    end
  end
end
