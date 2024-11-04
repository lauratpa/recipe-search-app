class RecipeFilter
  ContradictionError = Class.new(StandardError)

  attr_reader :or, :and

  def initialize(params)
    @or = params.fetch(:ingredient_ids, {}).fetch(:or, []).reject(&:blank?)
    @and = params.fetch(:ingredient_ids, {}).fetch(:and, []).reject(&:blank?)
  end

  def new_with(or_id: nil, and_id: nil)
    RecipeFilter.new(to_params).tap do |new_filter|
      new_filter.add_to_or(or_id)
      new_filter.add_to_and(and_id)
    end
  end

  def new_without(or_id: nil, and_id: nil)
    RecipeFilter.new(to_params).tap do |new_filter|
      new_filter.remove_from_or(or_id)
      new_filter.remove_from_and(and_id)
    end
  end

  def none?
    @or.empty? && @and.empty?
  end

  def or_include?(ingredient_id)
    @or.include?(ingredient_id.to_s)
  end

  def and_include?(ingredient_id)
    @and.include?(ingredient_id.to_s)
  end

  def add_to_or(ingredient_id)
    return if ingredient_id.blank?
    raise ContradictionError if @and.include?(ingredient_id)

    @or << ingredient_id
  end

  def add_to_and(ingredient_id)
    return if ingredient_id.blank?
    raise ContradictionError if @or.include?(ingredient_id)

    @and << ingredient_id
  end

  def remove_from_or(ingredient_id)
    @or.delete(ingredient_id)
  end

  def remove_from_and(ingredient_id)
    @and.delete(ingredient_id)
  end

  def to_params
    { ingredient_ids: { or: @or.dup, and: @and.dup } }
  end
end
