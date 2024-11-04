class RecipeFilter
  ContradictionError = Class.new(StandardError)

  attr_reader :or, :and, :not

  def initialize(params)
    @or = params.fetch(:ingredient_ids, {}).fetch(:or, []).reject(&:blank?)
    @and = params.fetch(:ingredient_ids, {}).fetch(:and, []).reject(&:blank?)
    @not = params.fetch(:ingredient_ids, {}).fetch(:not, []).reject(&:blank?)
  end

  def new_with(or_id: nil, and_id: nil, not_id: nil)
    RecipeFilter.new(to_params).tap do |new_filter|
      new_filter.add_to_or(or_id)
      new_filter.add_to_and(and_id)
      new_filter.add_to_not(not_id)
    end
  end

  def new_without(or_id: nil, and_id: nil, not_id: nil)
    RecipeFilter.new(to_params).tap do |new_filter|
      new_filter.remove_from_or(or_id)
      new_filter.remove_from_and(and_id)
      new_filter.remove_from_not(not_id)
    end
  end

  def none?
    @or.empty? && @and.empty? && @not.empty?
  end

  def only_or?
    @or.any? && @and.empty? && @not.empty?
  end

  def only_and?
    @and.any? && @or.empty? && @not.empty?
  end

  def only_not?
    @or.empty? && @and.empty? && @not.any?
  end

  def and_or?
    @or.any? && @and.any? && @not.empty?
  end

  def and_not?
    @or.empty? && @and.any? && @not.any?
  end

  def or_not?
    @or.any? && @and.empty? && @not.any?
  end

  def all?
    @or.any? && @and.any? && @not.any?
  end

  def or_include?(ingredient_id)
    @or.include?(ingredient_id.to_s)
  end

  def and_include?(ingredient_id)
    @and.include?(ingredient_id.to_s)
  end

  def not_include?(ingredient_id)
    @not.include?(ingredient_id.to_s)
  end

  def add_to_or(ingredient_id)
    return if ingredient_id.blank?
    raise ContradictionError if and_include?(ingredient_id) || not_include?(ingredient_id)

    @or << ingredient_id unless @or.include?(ingredient_id)
  end

  def add_to_and(ingredient_id)
    return if ingredient_id.blank?
    raise ContradictionError if or_include?(ingredient_id) || not_include?(ingredient_id)

    @and << ingredient_id unless @and.include?(ingredient_id)
  end

  def add_to_not(ingredient_id)
    return if ingredient_id.blank?
    raise ContradictionError if or_include?(ingredient_id) || and_include?(ingredient_id)

    @not << ingredient_id unless @not.include?(ingredient_id)
  end

  def remove_from_or(ingredient_id)
    @or.delete(ingredient_id)
  end

  def remove_from_and(ingredient_id)
    @and.delete(ingredient_id)
  end

  def remove_from_not(ingredient_id)
    @not.delete(ingredient_id)
  end

  def to_params
    { ingredient_ids: { or: @or.dup, and: @and.dup, not: @not.dup } }
  end
end
