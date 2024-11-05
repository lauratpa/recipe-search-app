require 'rails_helper'

RSpec.describe 'Ingredients', type: :request do
  context "POST#search" do
    it "returns ingredients matching the search" do
      category = create(:category)

      bananas = create(:ingredient, name: 'bananas')
      apples = create(:ingredient, name: 'apples')

      bananas_recipe = create(:recipe, title: 'Bananas recipe', category: category)
        .tap { |recipe| recipe.ingredients << bananas }
      apples_recipe = create(:recipe, title: 'Apples recipe', category: category)
        .tap { |recipe| recipe.ingredients << apples }

      post search_ingredients_path, params: { search: "banana", operator: :or_id }

      expect(response).to have_http_status(200)
      expect(response.body).to include("bananas (1)")
      expect(response.body).not_to include("apples")
    end

    it 'does not return ingredients already chose' do
      category = create(:category)

      butter = create(:ingredient, name: 'butter')
        .tap { |ingredient| ingredient.recipes << create(:recipe, category: category) }
      peanut_butter = create(:ingredient, name: 'peanut butter')
        .tap { |ingredient| ingredient.recipes << create(:recipe, category: category) }
      buttermilk = create(:ingredient, name: 'buttermilk')
        .tap { |ingredient| ingredient.recipes << create(:recipe, category: category) }

      post(
        search_ingredients_path,
        params: {
          search: "butter",
          ingredient_ids: { and: [ peanut_butter.id ], or: [ buttermilk.id ] },
          operator: 'or_id'
        }
      )

      expect(response).to have_http_status(200)
      expect(response.body).to include("butter (1)")
      expect(response.body).not_to include("buttermilk")
      expect(response.body).not_to include("peanut butter")
    end
  end
end
