require 'rails_helper'

RSpec.describe RecipeFilter do
  it 'contains all the selected filters' do
    params = ActionController::Parameters.new(ingredient_ids: { or: [ '1', '2' ] })

    filter = RecipeFilter.new(params)

    expect(filter.or).to eq([ '1', '2' ])
  end

  describe '#new_with' do
    it 'contains the selected filters' do
      params = ActionController::Parameters.new(ingredient_ids: { or: [ '1', '2' ] })

      filter = RecipeFilter.new(params)

      new_filter = filter.new_with(or_id: '3')

      expect(new_filter.or).to eq([ '1', '2', '3' ])
    end
  end

  describe '#new_without' do
    it 'contains the selected filters' do
      params = ActionController::Parameters.new(ingredient_ids: { or: [ '1', '2' ] })

      filter = RecipeFilter.new(params)

      new_filter = filter.new_without(or_id: '1')

      expect(new_filter.or).to eq([ '2' ])
    end
  end
end
