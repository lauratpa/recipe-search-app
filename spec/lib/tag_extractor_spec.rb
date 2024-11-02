require 'spec_helper'
require './app/lib/tag_extractor'

RSpec.describe TagExtractor do
  it 'extracts ingredient name' do
    line = "1 cup all-purpose flour"

    expect(TagExtractor.call(line)).to eq("all purpose flour")
  end

  it 'removes digits' do
    lines = [
      "1 ½ cups of sugar",
      "⅓ cups of sugar",
      "¼ cups of sugar",
      "¾ cups of sugar",
      "⅛ cups of sugar",
      "⅔ cups of sugar"
    ]

    expect(lines.map { |line| TagExtractor.call(line) }.uniq).to eq([ "sugar" ])
  end

  it 'removes measurements' do
    lines = [
      "1 ½ cups of apples",
      "1 teaspoon of apples",
      "2 teaspoons of apples",
      "3 tablespoons of apples",
      "2 (16 ounce) cans of apples",
      "1 (.25 ounce) package of apples",
      "1 small apple",
      "2 medium apples",
      "3 large apples",
      "4 ounces of apples",
      "1 bottle of apples"
    ]

    expect(lines.map { |line| TagExtractor.call(line) }.uniq).to eq([ "apples" ])
  end

  it 'removes adjectives', :aggregate_failures do
    expect(TagExtractor.call("1 cup warm water")).to eq("water")
    expect(TagExtractor.call("1 cup fresh blueberries")).to eq("blueberries")
    expect(TagExtractor.call("¼ cup pure maple syrup")).to eq("maple syrup")
  end

  it 'removes cooking methods', :aggregate_failures do
    expect(TagExtractor.call("3 (12 ounce) packages refrigerated biscuits dough")).to eq("biscuits dough")
    expect(TagExtractor.call("2 teaspoons ground cinnamon")).to eq("cinnamon")
    expect(TagExtractor.call("1 cup packed brown sugar")).to eq("brown sugar")
    expect(TagExtractor.call("½ cup chopped walnuts")).to eq("walnuts")
    expect(TagExtractor.call("1 ½ cups cubed winter squash")).to eq("winter squash")
    expect(TagExtractor.call("1 cup scalded milk")).to eq("milk")
    expect(TagExtractor.call("2 ⅓ cups mashed overripe bananas")).to eq("bananas")
    expect(TagExtractor.call("2 cups shredded sharp Cheddar cheese")).to eq("cheddar cheese")
    expect(TagExtractor.call("2 medium ripe bananas, sliced")).to eq("bananas")
    expect(TagExtractor.call("2 cups grated zucchini")).to eq("zucchini")
    expect(TagExtractor.call("2 cups pre-cooked white corn meal (such as P.A.N.®)")).to eq("white corn meal")
    expect(TagExtractor.call("¼ cup butter, chilled cubed")).to eq("butter")
    expect(TagExtractor.call("¼ cup butter, divided")).to eq("butter")
    expect(TagExtractor.call("¾ cup butter, melted and cooled to lukewarm",)).to eq("butter")
    expect(TagExtractor.call("3 tablespoons butter, softened")).to eq("butter")
    expect(TagExtractor.call("1 sheet frozen puff pastry, thawed")).to eq("puff pastry")
    expect(TagExtractor.call("1 lemon, zested and juiced")).to eq("lemons")
    expect(TagExtractor.call("1 cup cranberries, halved")).to eq("cranberries")
  end

  it 'removes sentences', :aggregate_failures do
    expect(TagExtractor.call("6 slices turkey bacon, cut into small pieces")).to eq("turkey bacon")
    expect(TagExtractor.call("1 teaspoon ground cinnamon, or to taste")).to eq("cinnamon")
    expect(TagExtractor.call("¼ cup vegetable oil, or as needed")).to eq("vegetable oil")
    expect(TagExtractor.call("7 tablespoons unsalted butter, chilled in freezer and cut into thin slices")).to eq("unsalted butter")
    expect(TagExtractor.call("2 tablespoons buttermilk for brushing")).to eq("buttermilk")
    expect(TagExtractor.call("Water to spray tops of loaves")).to eq("water")
    expect(TagExtractor.call("1 (16.3 ounce) package refrigerated buttermilk biscuit dough, separated and each portion cut into quarters")).to eq("buttermilk biscuit dough")
    expect(TagExtractor.call("1 ½ cups buttermilk, at room temperature")).to eq("buttermilk")
    expect(TagExtractor.call("3 1/4-inch-thick slices peeled fresh ginger")).to eq("ginger")
    expect(TagExtractor.call("1 ⅓ pounds ube (purple yam), peeled and cut into 1/4-inch-thick fries")).to eq("ube")
    expect(TagExtractor.call("⅓ cup low fat (1%) milk")).to eq("low fat milk")
    expect(TagExtractor.call("28 ounces 93% lean ground turkey")).to eq("turkey")
    expect(TagExtractor.call("1 10-inch banneton (proofing basket)")).to eq("banneton")
    expect(TagExtractor.call("2 (.25 ounce) packages quick-rising yeast (such as Fleischmann's RapidRise®)")).to eq("quick rising yeast")
  end

  it 'removes Granny Smith instructions', :aggregate_failures do
    expect(TagExtractor.call("1 Granny Smith apple - peeled, cored and coarsely shredded")).to eq("granny smith apples")
    expect(TagExtractor.call("3 Granny Smith apples - peeled, cored and sliced")).to eq("granny smith apples")
  end

  it 'saves cream of tatar and soups', :aggregate_failures do
    expect(TagExtractor.call("½ teaspoon cream of tartar")).to eq("cream of tartar")
    expect(TagExtractor.call("2 (10.75 ounce) cans cream of mushroom soup")).to eq("cream of mushroom soup")
    expect(TagExtractor.call("¼ cup extra virgin olive oil")).to eq("extra virgin olive oil")
    expect(TagExtractor.call("1 tablespoon extra-virgin olive oil")).to eq("extra-virgin olive oil")
  end

  it 'saves almonds' do
    expect(TagExtractor.call("¼ cup unsweetened almond milk")).to eq("unsweetened almond milk")
    expect(TagExtractor.call("⅓ cup toasted slivered almonds")).to eq("almonds")
    expect(TagExtractor.call("2 cups finely ground almond flour")).to eq("almond flour")
    expect(TagExtractor.call("½ teaspoon almond extract")).to eq("almond extract")
  end
end
