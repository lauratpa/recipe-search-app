require "rails_helper"

RSpec.describe RecipeFilter do
  let(:params) do
    ActionController::Parameters.new(ingredient_ids: {or: ["1", "2"], and: ["4"]})
  end
  let(:filter) { RecipeFilter.new(params) }

  it "contains all the selected filters" do
    expect(filter.or).to eq(["1", "2"])
    expect(filter.and).to eq(["4"])
  end

  describe "#new_with" do
    it "contains the selected filters" do
      new_filter = filter.new_with(or_id: "3", and_id: "5")

      expect(new_filter.or).to eq(["1", "2", "3"])
      expect(new_filter.and).to eq(["4", "5"])
    end
  end

  describe "#new_without" do
    it "contains the selected filters" do
      new_filter = filter.new_without(or_id: "1", and_id: "4")

      expect(new_filter.or).to eq(["2"])
      expect(new_filter.and).to be_empty
    end
  end

  describe "#add_to_or" do
    context "raise error if given id already exists for another operator" do
      it "adds the filter" do
        expect { filter.add_to_or("4") }.to raise_error(RecipeFilter::ContradictionError)
      end
    end
  end

  describe "#add_to_and" do
    context "raise error if given id already exists for another operator" do
      it "adds the filter" do
        expect { filter.add_to_and("1") }.to raise_error(RecipeFilter::ContradictionError)
      end
    end
  end
end
