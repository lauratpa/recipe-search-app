require 'rails_helper'

RSpec.describe 'Ingredients', type: :request do
  context "POST#search" do
    it "returns 200" do
      category = create(:category)

      bananas = create(:ingredient, name: 'bananas')
      apples = create(:ingredient, name: 'apples')

      bananas_recipe = create(:recipe, title: 'Bananas recipe', category: category)
        .tap { |recipe| recipe.ingredients << bananas }
      apples_recipe = create(:recipe, title: 'Apples recipe', category: category)
        .tap { |recipe| recipe.ingredients << apples }

      post search_ingredients_path, params: { search: "banana" }

      expect(response).to have_http_status(200)
      expect(response.body).to include("bananas (1)")
      expect(response.body).not_to include("apples")
    end
  end
end
