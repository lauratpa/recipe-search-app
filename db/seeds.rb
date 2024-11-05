# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
json_file = File.read("db/recipes-en.json")

data = JSON.parse(json_file)

categories_data = data.map do |recipe_hsh|
  {name: recipe_hsh.fetch("category")}
end.uniq

Category.upsert_all(categories_data, unique_by: :name)

categories = Category.pluck(:name, :id).to_h

data.each do |recipe_hsh|
  Recipe.transaction do
    transformed_image_url =
      begin
        CGI.unescape(URI(recipe_hsh.fetch("image")).query.gsub("url=", ""))
      rescue
        recipe_hsh.fetch("image")
      end

    recipe = Recipe.find_or_create_by(
      title: recipe_hsh.fetch("title"),
      cook_time: recipe_hsh.fetch("cook_time"),
      prep_time: recipe_hsh.fetch("prep_time"),
      author: recipe_hsh.fetch("author"),
      image_url: transformed_image_url,
      rating: recipe_hsh.fetch("ratings"),
      details: recipe_hsh.fetch("ingredients"),
      category_id: categories.fetch(recipe_hsh.fetch("category"))
    )

    recipe_ingredients = recipe_hsh.fetch("ingredients").map do |ingredient_str|
      ingredient_tag = TagExtractor.call(ingredient_str)
      next if ingredient_tag.blank?

      ingredient = Ingredient.find_or_create_by(name: ingredient_tag)

      {ingredient_id: ingredient.id, recipe_id: recipe.id}
    end.compact

    RecipeIngredient.upsert_all(recipe_ingredients, unique_by: %i[ingredient_id recipe_id])
  end
end
