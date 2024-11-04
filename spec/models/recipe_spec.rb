require 'rails_helper'

RSpec.describe Recipe, type: :model do
  let(:category) { create(:category) }
  let(:bananas) { create(:ingredient, name: 'bananas') }
  let(:apples) { create(:ingredient, name: 'apples') }
  let(:oranges) { create(:ingredient, name: 'oranges') }
  let(:kiwis) { create(:ingredient, name: 'kiwis') }

  def create_recipe(rating: '5.0', ingredients:)
    create(
      :recipe,
      title: "#{ingredients.map(&:name).join(' ').capitalize} #{rating}",
      category: category, rating: rating
    ).tap { |recipe| recipe.ingredients << ingredients }
  end

  describe '.with_ingredients' do
    it 'returns recipe which contain the given ingredient ids' do
      create_recipe(ingredients: [ bananas ])
      apples_recipe = create_recipe(ingredients: [ apples ])

      expect(described_class.with_ingredients([ apples.id ])).to contain_exactly(apples_recipe)
    end
  end

  describe '.or_ingredients_by_rating' do
    it 'orders recipes by rating' do
      worse_bananas_apples_oranges_recipe = create_recipe(
        rating: 3.9, ingredients: [ bananas, apples, oranges ]
      )
      better_bananas_apples_oranges_recipe = create_recipe(
        rating: 4.0, ingredients: [ bananas, apples, oranges ]
      )
      apples_oranges_recipe = create_recipe(ingredients: [ apples, oranges ])
      oranges_recipe = create_recipe(ingredients: [ oranges ])
      create_recipe(ingredients: [ kiwis ]) # not returned

      expect(described_class.or_ingredients_by_rating([ bananas.id, apples.id, oranges.id ]))
        .to eq(
          [
            better_bananas_apples_oranges_recipe,
            worse_bananas_apples_oranges_recipe,
            apples_oranges_recipe,
            oranges_recipe
          ]
        )
    end
  end

  describe '.and_ingredients_by_rating' do
    it 'orders recipes by rating' do
      worse_bananas_apples_oranges_recipe = create_recipe(
        rating: 3.9, ingredients: [ bananas, apples, oranges ]
      )
      better_bananas_apples_recipe = create_recipe(
        rating: 4.0, ingredients: [ bananas, apples ]
      )

      create_recipe(ingredients: [ bananas, oranges ]) # missing apples
      create_recipe(ingredients: [ oranges ]) # missing bananas and apples

      expect(described_class.and_ingredients_by_rating([ bananas.id, apples.id ]))
        .to eq([ better_bananas_apples_recipe, worse_bananas_apples_oranges_recipe ])
    end
  end

  describe '.and_or_ingredients_by_rating' do
    it 'orders recipes by rating' do
      bananas_apples_oranges_recipe = create_recipe(ingredients: [ bananas, apples, oranges ])
      bananas_apples_kiwis_recipe = create_recipe(ingredients: [ bananas, apples, kiwis ])

      create_recipe(ingredients: [ apples, oranges ]) # missing bananas
      create_recipe(ingredients: [ oranges ]) # missing bananas
      create_recipe(ingredients: [ kiwis ]) # missing bananas and apples

      result = described_class.and_or_ingredients_by_rating(
        and_ingredient_ids: [ bananas.id, apples.id ],
        or_ingredient_ids: [ kiwis.id ]
      )
      expect(result).to eq([ bananas_apples_kiwis_recipe, bananas_apples_oranges_recipe ])
      expect(result.first[:ingredient_count]).to eq(3) # kiwis are included in the count
      expect(result.last[:ingredient_count]).to eq(2)
    end
  end

  describe '.not_ingredients_by_rating' do
    it 'orders recipes by rating' do
      bananas_recipe = create_recipe(ingredients: [ bananas ])

      create_recipe(ingredients: [ bananas, apples ]) # contains apples
      create_recipe(ingredients: [ apples ]) # contains apples

      expect(described_class.not_ingredients_by_rating([ apples.id ]))
        .to eq([ bananas_recipe ])
    end
  end

  describe '.not_or_ingredients_by_rating' do
    it 'orders recipes by rating' do
      bananas_and_oranges_recipe = create_recipe(ingredients: [ bananas, oranges ])

      create_recipe(ingredients: [ bananas, apples ]) # contains apples

      expect(
        described_class.not_or_ingredients_by_rating(
          not_ingredient_ids: [ apples.id ],
          or_ingredient_ids: [ oranges.id ]
        )
      ).to eq([ bananas_and_oranges_recipe ])
    end
  end

  describe '.and_not_ingredients_by_rating' do
    it 'orders recipes by rating' do
      bananas_and_oranges_recipe = create_recipe(ingredients: [ bananas, oranges ])

      create_recipe(ingredients: [ bananas, apples ]) # contains apples
      create_recipe(ingredients: [ apples ]) # contains apples

      expect(
        described_class.and_not_ingredients_by_rating(
          and_ingredient_ids: [ bananas.id ],
          not_ingredient_ids: [ apples.id ]
        )
      ).to eq([ bananas_and_oranges_recipe ])
    end
  end

  describe '.and_not_or_ingredients_by_rating' do
    it 'orders recipes by rating' do
      worse_bananas_oranges_kiwis_recipe = create_recipe(ingredients: [ bananas, oranges ], rating: 3.9)
      better_bananas_kiwis_recipe = create_recipe(ingredients: [ bananas, kiwis ], rating: 4.8)

      create_recipe(ingredients: [ bananas, apples, oranges ]) # contains apples
      create_recipe(ingredients: [ apples, kiwis ]) # contains apples
      create_recipe(ingredients: [ oranges ]) # missing bananas

      expect(
        described_class.and_not_or_ingredients_by_rating(
          and_ingredient_ids: [ bananas.id ],
          not_ingredient_ids: [ apples.id ],
          or_ingredient_ids: [ kiwis.id ]
        )
      )
        .to eq([ better_bananas_kiwis_recipe, worse_bananas_oranges_kiwis_recipe ])
    end
  end
end
