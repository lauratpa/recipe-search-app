require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  describe '.search_by_name' do
    it 'returns ingredients which contain the given name' do
      bananas = create(:ingredient, name: 'bananas')
      apples = create(:ingredient, name: 'apples')

      expect(Ingredient.search_by_name('banana')).to contain_exactly(bananas)
    end
  end

  describe '.order_by_recipe_count' do
    it 'orders ingredients by recipe count' do
      bananas = create(:ingredient, name: 'bananas')
      apples = create(:ingredient, name: 'apples')

      category = create(:category)
      create(:recipe, category: category, title: 'Bananas recipe')
        .tap { |recipe| recipe.ingredients << bananas }
      create(:recipe, category: category, title: 'Bananas recipe 2')
        .tap { |recipe| recipe.ingredients << bananas }
      create(:recipe, category: category, title: 'Apples recipe')
        .tap { |recipe| recipe.ingredients << apples }

      expect(Ingredient.order_by_recipe_count).to eq([ bananas, apples ])
    end
  end
end
