require "rails_helper"

RSpec.describe "Recipes", type: :request do
  let(:category) { create(:category) }

  context "GET#index" do
    let(:bananas) { create(:ingredient, name: "bananas") }
    let(:apples) { create(:ingredient, name: "apples") }
    let(:oranges) { create(:ingredient, name: "oranges") }
    let(:kiwis) { create(:ingredient, name: "kiwis") }

    def create_recipe(ingredients:, rating: "5.0")
      create(
        :recipe,
        title: "#{ingredients.map(&:name).join(" ").capitalize} #{rating}",
        category: category, rating: rating
      ).tap { |recipe| recipe.ingredients << ingredients }
    end

    context "when visiting the page for the first time" do
      it "shows 10 best ranked recipes" do
        (3.0..5.0).step(0.2).each do |rating|
          create(:recipe, category: category, rating: rating)
        end

        get recipes_path

        expect(response).to have_http_status(200)
        # Page contains 10 highest ranked recipes
        expect(response.body)
          .to include("3.2", "3.4", "3.6", "3.8", "4.0", "4.2", "4.4", "4.6", "4.8", "5.0")
        # Page does not contain the lowest ranked recipe
        expect(response.body).not_to include("3.0")
        expect(response.body).to include("Found 11 recipes")
      end
    end

    context "when using limit parameter" do
      it "shows the specified number of recipes" do
        (3.0..5.0).step(1).each do |rating|
          create(:recipe, category: category, rating: rating)
        end

        get recipes_path, params: {limit: 2}

        expect(response).to have_http_status(200)
        # Page contains 2 highest ranked recipes
        expect(response.body).to include("5.0", "4.0")
        # Page does not contain the lowest ranked recipe
        expect(response.body).not_to include("3.0")
        expect(response.body).to include("Found 3 recipes")
      end
    end

    context "when using offset paramaeter" do
      it "skips the specified number of recipes" do
        (3.0..5.0).step(1).each do |rating|
          create(:recipe, category: category, rating: rating)
        end

        get recipes_path, params: {limit: 2, page: 2}

        expect(response).to have_http_status(200)
        # Page contains highest ranked recipes from the second page
        expect(response.body).to include("3.0")
        # Page does not contain the lowest ranked recipe
        expect(response.body).not_to include("5.0", "4.0")
        expect(response.body).to include("Found 3 recipes")
      end
    end

    context "when visiting page with selected OR ingredients" do
      it "shows recipes that contain any of the selected ingredients" do
        bananas_recipe = create_recipe(ingredients: [bananas])
        apples_recipe = create_recipe(ingredients: [apples])
        oranges_recipe = create_recipe(ingredients: [oranges])

        get recipes_path, params: {ingredient_ids: {or: [bananas.id, oranges.id]}}

        expect(response).to have_http_status(200)
        # Page contains recipes for the selected ingredients
        expect(response.body).to include(bananas_recipe.title, oranges_recipe.title)
        # Page does not contain recipes missing the ingredients
        expect(response.body).not_to include(apples_recipe.title)
        expect(response.body).to include("Found 2 recipes")
      end
    end

    context "when visiting page with selected AND ingredients" do
      it "shows recipes that contain any of the selected ingredients" do
        bananas_and_oranges_recipe = create_recipe(ingredients: [bananas, oranges])
        oranges_recipe = create_recipe(ingredients: [oranges])
        apples_recipe = create_recipe(ingredients: [apples])

        get recipes_path, params: {ingredient_ids: {and: [bananas.id, oranges.id]}}

        expect(response).to have_http_status(200)
        # Page contains recipes for the selected ingredients
        expect(response.body).to include(bananas_and_oranges_recipe.title)
        # Page does not contain recipes missing the ingredients
        expect(response.body).not_to include(apples_recipe.title, oranges_recipe.title)
        expect(response.body).to include("Found 1 recipe")
      end
    end

    context "when visiting page with selected AND and OR ingredients" do
      it "shows recipes that contain any of the selected ingredients" do
        bananas_and_oranges_recipe = create_recipe(ingredients: [bananas, oranges])
        bananas_oranges_and_kiwis_recipe = create_recipe(ingredients: [bananas, oranges, kiwis])
        bananas_oranges_and_apples_recipe = create_recipe(ingredients: [bananas, oranges, apples])
        bananas_and_kiwis_recipe = create_recipe(ingredients: [bananas, kiwis])
        oranges_recipe = create_recipe(ingredients: [oranges])
        apples_recipe = create_recipe(ingredients: [apples])
        kiwis_recipe = create_recipe(ingredients: [kiwis])

        params = {ingredient_ids: {and: [bananas.id, oranges.id], or: [kiwis.id]}}

        get recipes_path, params: params

        expect(response).to have_http_status(200)

        # Page contains recipes for the selected ingredients
        expect(response.body).to include(
          bananas_oranges_and_kiwis_recipe.title,
          bananas_oranges_and_apples_recipe.title,
          bananas_and_oranges_recipe.title
        )
        # Page does not contain recipes missing the ingredients
        expect(response.body).not_to include(
          bananas_and_kiwis_recipe.title,
          kiwis_recipe.title,
          apples_recipe.title,
          oranges_recipe.title
        )
        expect(response.body).to include("Found 3 recipes")
      end
    end

    context "when visiting page with selected NOT ingredients" do
      it "shows recipes that do not contain any of the selected ingredients" do
        bananas_and_oranges_recipe = create_recipe(ingredients: [bananas, oranges])
        bananas_and_kiwis_recipe = create_recipe(ingredients: [bananas, kiwis])
        apples_recipe = create_recipe(ingredients: [apples])
        kiwis_recipe = create_recipe(ingredients: [kiwis])

        params = {ingredient_ids: {not: [kiwis.id]}}

        get recipes_path, params: params

        expect(response).to have_http_status(200)

        # Page contains recipes that do not contain the selected ingredients
        expect(response.body).to include(
          bananas_and_oranges_recipe.title,
          apples_recipe.title
        )
        # Page does not contain recipes that contain the selected ingredients
        expect(response.body).not_to include(
          bananas_and_kiwis_recipe.title,
          kiwis_recipe.title
        )
        expect(response.body).to include("Found 2 recipes")
      end
    end

    context "when visiting page with selected NOT and OR ingredients" do
      it "shows recipes that do not contain any of the NOT ingredients but contains OR ingredients" do
        bananas_and_oranges_recipe = create_recipe(ingredients: [bananas, oranges])
        oranges_and_kiwis_recipe = create_recipe(ingredients: [oranges, kiwis])
        apples_recipe = create_recipe(ingredients: [apples])
        kiwis_recipe = create_recipe(ingredients: [kiwis])

        params = {ingredient_ids: {not: [kiwis.id], or: [oranges.id]}}

        get recipes_path, params: params

        expect(response).to have_http_status(200)

        # Page contains recipes that do not contain the NOT ingredients
        # but contain the OR ingredients
        expect(response.body).to include(
          bananas_and_oranges_recipe.title
        )
        # Page does not contain recipes that contain the NOT ingredients
        # nor recipes with no OR ingredients
        expect(response.body).not_to include(
          oranges_and_kiwis_recipe.title,
          apples_recipe.title,
          kiwis_recipe.title
        )
        expect(response.body).to include("Found 1 recipe")
      end
    end

    context "when visiting page with selected NOT and AND ingredients" do
      it "shows recipes that do not contain any of the NOT ingredients but contains AND ingredients" do
        bananas_and_oranges_recipe = create_recipe(ingredients: [bananas, oranges])
        oranges_and_kiwis_recipe = create_recipe(ingredients: [oranges, kiwis])
        apples_recipe = create_recipe(ingredients: [apples])
        kiwis_recipe = create_recipe(ingredients: [kiwis])

        params = {ingredient_ids: {not: [kiwis.id], and: [oranges.id]}}

        get recipes_path, params: params

        expect(response).to have_http_status(200)

        # Page contains recipes that do not contain the NOT ingredients
        # but contain the OR ingredients
        expect(response.body).to include(
          bananas_and_oranges_recipe.title
        )
        # Page does not contain recipes that contain the NOT ingredients
        # nor recipes with no OR ingredients
        expect(response.body).not_to include(
          oranges_and_kiwis_recipe.title,
          apples_recipe.title,
          kiwis_recipe.title
        )
        expect(response.body).to include("Found 1 recipe")
      end
    end

    context "when visiting page with selected NOT, AND and OR ingredients" do
      it "shows recipes that do not contain any of the selected ingredients" do
        oranges_and_apples_recipe = create_recipe(ingredients: [oranges, apples])
        oranges_bananas_and_kiwis_recipe = create_recipe(ingredients: [oranges, bananas, kiwis])
        oranges_bananas_and_apples_recipe = create_recipe(ingredients: [oranges, apples, bananas])
        apples_recipe = create_recipe(ingredients: [apples])
        kiwis_recipe = create_recipe(ingredients: [kiwis])

        params = {ingredient_ids: {not: [kiwis.id], and: [oranges.id], or: [bananas.id]}}

        get recipes_path, params: params

        expect(response).to have_http_status(200)

        # Page contains recipes that do not contain the selected ingredients
        expect(response.body).to include(
          oranges_and_apples_recipe.title,
          oranges_bananas_and_apples_recipe.title
        )
        # Page does not contain recipes that contain the selected ingredients
        expect(response.body).not_to include(
          oranges_bananas_and_kiwis_recipe.title,
          apples_recipe.title,
          kiwis_recipe.title
        )
        expect(response.body).to include("Found 2 recipes")
      end
    end
  end

  context "GET#show" do
    it "shows recipe details" do
      recipe = create(:recipe, category: category)

      get recipe_path(recipe)

      expect(response).to have_http_status(200)
      expect(response.body).to include(recipe.title)
    end
  end
end
