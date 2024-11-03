class RecipeFilter
  attr_reader :or

  def initialize(params)
    @or = params.fetch(:ingredient_ids, {}).fetch(:or, [])
  end

  def new_with(or_id: nil)
    RecipeFilter.new(to_params).tap do |new_filter|
      new_filter.add_to_or(or_id)
    end
  end

  def new_without(or_id: nil)
    RecipeFilter.new(to_params).tap do |new_filter|
      new_filter.remove_from_or(or_id)
    end
  end

  def none?
    @or.empty?
  end

  def or_include?(ingredient_id)
    @or.include?(ingredient_id.to_s)
  end

  def add_to_or(ingredient_id)
    @or << ingredient_id
  end

  def remove_from_or(ingredient_id)
    @or.delete(ingredient_id)
  end

  def to_params
    { ingredient_ids: { or: @or.dup } }
  end
end
