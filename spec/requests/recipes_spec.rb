require 'rails_helper'

RSpec.describe 'Recipes', type: :request do
  context "GET#index" do
    context 'when visiting the page for the first time' do
      it 'shows 10 best ranked recipes' do
        category = create(:category)
        (3.0..5.0).step(0.2).each do |rating|
          recipe = create(:recipe, category: category, rating: rating)
        end

        get recipes_path

        expect(response).to have_http_status(200)

        # Page contains 10 highest ranked recipes
        expect(response.body)
          .to include("3.2", "3.4", "3.6", "3.8", "4.0", "4.2", "4.4", "4.6", "4.8", "5.0")
        # Page does not contain the lowest ranked recipe
        expect(response.body).not_to include("3.0")
      end
    end

    context 'when visiting page with selected OR ingredients' do
      it 'shows recipes that contain any of the selected ingredients' do
        category = create(:category)

        bananas = create(:ingredient, name: 'bananas')
        apples = create(:ingredient, name: 'apples')
        oranges = create(:ingredient, name: 'oranges')

        bananas_recipe = create(:recipe, title: 'Bananas recipe', category: category)
          .tap { |recipe| recipe.ingredients << bananas }
        apples_recipe = create(:recipe, title: 'Apples recipe', category: category)
          .tap { |recipe| recipe.ingredients << apples }
        oranges_recipe = create(:recipe, title: 'Oranges recipe', category: category)
          .tap { |recipe| recipe.ingredients << oranges }

        get recipes_path, params: { ingredient_ids: {  or: [ bananas.id, oranges.id ] } }

        expect(response).to have_http_status(200)

        # Page contains recipes for the selected ingredients
        expect(response.body).to include(bananas_recipe.title, oranges_recipe.title)
        # Page does not contain recipes missing the ingredients
        expect(response.body).not_to include(apples_recipe.title)
      end
    end

    context 'when visiting page with selected AND ingredients' do
      it 'shows recipes that contain any of the selected ingredients' do
        category = create(:category)

        bananas = create(:ingredient, name: 'bananas')
        apples = create(:ingredient, name: 'apples')
        oranges = create(:ingredient, name: 'oranges')

        bananas_and_oranges_recipe = create(:recipe, title: 'Bananas and oranges recipe', category: category)
          .tap { |recipe| recipe.ingredients << [ bananas, oranges ] }
        oranges_recipe = create(:recipe, title: 'Oranges recipe', category: category)
          .tap { |recipe| recipe.ingredients << oranges }
        apples_recipe = create(:recipe, title: 'Apples recipe', category: category)
          .tap { |recipe| recipe.ingredients << apples }

        get recipes_path, params: { ingredient_ids: {  and: [ bananas.id, oranges.id ] } }

        expect(response).to have_http_status(200)

        # Page contains recipes for the selected ingredients
        expect(response.body).to include(bananas_and_oranges_recipe.title)
        # Page does not contain recipes missing the ingredients
        expect(response.body).not_to include(apples_recipe.title, oranges_recipe.title)
      end
    end

    context 'when visiting page with selected AND and OR ingredients' do
      it 'shows recipes that contain any of the selected ingredients' do
        category = create(:category)

        bananas = create(:ingredient, name: 'bananas')
        apples = create(:ingredient, name: 'apples')
        oranges = create(:ingredient, name: 'oranges')
        kiwis = create(:ingredient, name: 'kiwis')

        bananas_and_oranges_recipe = create(:recipe, title: 'Bananas and oranges recipe', category: category)
          .tap { |recipe| recipe.ingredients << [ bananas, oranges ] }
        oranges_recipe = create(:recipe, title: 'Oranges recipe', category: category)
          .tap { |recipe| recipe.ingredients << oranges }
        apples_recipe = create(:recipe, title: 'Apples recipe', category: category)
          .tap { |recipe| recipe.ingredients << apples }
        kiwis_recipe = create(:recipe, title: 'Kiwis recipe', category: category)
          .tap { |recipe| recipe.ingredients << kiwis }


        params = {
          ingredient_ids: {
            and: [ bananas.id, oranges.id ],
            or: [ kiwis.id ]
          }
        }

        get recipes_path, params: params

        expect(response).to have_http_status(200)

        # Page contains recipes for the selected ingredients
        expect(response.body).to include(bananas_and_oranges_recipe.title, kiwis_recipe.title)
        # Page does not contain recipes missing the ingredients
        expect(response.body).not_to include(apples_recipe.title, oranges_recipe.title)
      end
    end
  end

  context 'GET#show' do
    it 'shows recipe details' do
      category = create(:category)
      recipe = create(:recipe, category: category)

      get recipe_path(recipe)

      expect(response).to have_http_status(200)
      expect(response.body).to include(recipe.title)
    end
  end
end
