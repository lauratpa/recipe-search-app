FactoryBot.define do
  factory :recipe do
    sequence(:title) { |n| "Recipe #{n}" }
    prep_time { 10 }
    cook_time { 15 }
    rating { 4.5 }
    author { 'Test author' }
    image_url { 'https://www.example.com/1234.jpg' }
    category
  end

  factory :recipe_with_ingredients, parent: :recipe do
    transient do
      ingredients_count { 3 }
    end

    after(:create) do |recipe, context|
      create_list(:recipe_ingredient, context.ingredients_count, recipe: recipe)
      recipe.reload
    end
  end
end
