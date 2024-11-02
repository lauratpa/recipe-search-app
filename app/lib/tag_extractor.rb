require "active_support/inflector"

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.uncountable "bacon"
  inflect.uncountable "basil"
  inflect.uncountable "banneton"
  inflect.uncountable "beer"
  inflect.uncountable "beef"
  inflect.uncountable "butter"
  inflect.uncountable "buttermilk"
  inflect.uncountable "broccoli"
  inflect.uncountable "broth"
  inflect.uncountable "cardamom"
  inflect.uncountable "chocolate"
  inflect.uncountable "cider"
  inflect.uncountable "cinnamon"
  inflect.uncountable "cilantro"
  inflect.uncountable "cheese"
  inflect.uncountable "cocoa"
  inflect.uncountable "coffee"
  inflect.uncountable "cornmeal"
  inflect.uncountable "corn meal"
  inflect.uncountable "cornstarch"
  inflect.uncountable "cream"
  inflect.uncountable "cumin"
  inflect.uncountable "dough"
  inflect.uncountable "extract"
  inflect.uncountable "filling"
  inflect.uncountable "flour"
  inflect.uncountable "garlic"
  inflect.uncountable "ghee"
  inflect.uncountable "ginger"
  inflect.uncountable "granola"
  inflect.uncountable "gum"
  inflect.uncountable "half-and-half"
  inflect.uncountable "honey"
  inflect.uncountable "juice"
  inflect.uncountable "ketchup"
  inflect.uncountable "lard"
  inflect.uncountable "margarine"
  inflect.uncountable "masa harina"
  inflect.uncountable "mayonnaise"
  inflect.uncountable "meal"
  inflect.uncountable "milk"
  inflect.uncountable "mix"
  inflect.uncountable "mustard"
  inflect.uncountable "nutmeg"
  inflect.uncountable "oil"
  inflect.uncountable "pan"
  inflect.uncountable "pastry"
  inflect.uncountable "paste"
  inflect.uncountable "pepper"
  inflect.uncountable "powder"
  inflect.uncountable "puree"
  inflect.uncountable "rosemary"
  inflect.uncountable "sage"
  inflect.uncountable "salt"
  inflect.uncountable "sauce"
  inflect.uncountable "seasoning"
  inflect.uncountable "shortening"
  inflect.uncountable "soda"
  inflect.uncountable "soup"
  inflect.uncountable "spray"
  inflect.uncountable "spread"
  inflect.uncountable "squash"
  inflect.uncountable "starter"
  inflect.uncountable "substitute"
  inflect.uncountable "sugar"
  inflect.uncountable "syrup"
  inflect.uncountable "sweetener"
  inflect.uncountable "tartar"
  inflect.uncountable "thyme"
  inflect.uncountable "turkey"
  inflect.uncountable "ube"
  inflect.uncountable "vinegar"
  inflect.uncountable "water"
  inflect.uncountable "yeast"
  inflect.uncountable "yogurt"
  inflect.uncountable "zest"
  inflect.uncountable "zucchini"
end

class TagExtractor
  SENTENCES = [
    "cut into",
    "to taste",
    "as needed",
    "if needed",
    "chilled in freezer",
    "for brushing",
    "for dusting",
    "for frying",
    "for deep frying",
    "for garnish",
    "for toppings",
    "for kneading",
    "for rolling",
    "for work surfaces",
    "for greasing",
    "to spray tops of loaves",
    "room temperature",
    "broken into",
    "cut in half"
  ]

  STOP_WORDS = [
    "and",
    "at",
    "each",
    "every",
    "more",
    "of",
    "or",
    "to"
  ]

  ADJECTIVES = [
    "cold",
    "fresh",
    "frozen",
    "medium",
    "large",
    "lean",
    "lukewarm",
    "overripe",
    "packed",
    "pre",
    "pure",
    "ripe",
    "sharp",
    "small",
    "thick",
    "thin",
    "warm"
  ]

  ADVERBS = [
    "coarsely",
    "extra",
    "finely",
    "firmly",
    "freshly",
    "lightly",
    "roughly",
    "slightly",
    "stiffly",
    "thinly"
  ]

  IRREGULAR_MEASUREMENTS = [
    "pinch",
    "pinches",
    "inch",
    "inches",
    "bunch",
    "bunches"
  ]

  MEASUREMENTS = [
    "bottles",
    "cans",
    "chunks",
    "containers",
    "cubes",
    "cups",
    "degrees",
    "envelopes",
    "florets",
    "gallons",
    "grams",
    "jars",
    "ounces",
    "packages",
    "pieces",
    "pints",
    "portions",
    "pounds",
    "quarts",
    "quarters",
    "sheets",
    "slices",
    "spoons",
    "tablespoons",
    "teaspoons",
    "wedges"
  ]

  COOKING_METHODS = [
    "beaten",
    "boiled",
    "boiling",
    "chilled",
    "cooled",
    "cored",
    "chopped",
    "cleaned",
    "cooked",
    "cubed",
    "crushed",
    "diced",
    "divided",
    "drained",
    "fries",
    "grated",
    "ground",
    "halved",
    "halves",
    "julienned",
    "juiced",
    "mashed",
    "melted",
    "minced",
    "peeled",
    "pitted",
    "refrigerated",
    "removed",
    "liquid reserved",
    "scalded",
    "seeded",
    "separated",
    "sifted",
    "shredded",
    "sliced",
    "slivered",
    "softened",
    "stewed",
    "toasted",
    "torn",
    "thawed",
    "warmed",
    "whisked",
    "zested"
  ]

  def initialize(line)
    @line = line
  end

  def call
    return difficult_match if difficult_match


    change_dashes_to_spaces
    remove_sentences
    remove_parentheses
    remove_commas_and_dots
    remove_digits
    remove_measurements
    remove_irregular_measurements
    remove_stop_words
    remove_cooking_methods
    remove_adjectives
    remove_adverbs

    line.gsub(/[[:space:]]+/, " ").strip.pluralize.downcase
  end

  def self.call(line)
    new(line).call
  end

  private

  attr_reader :line

  def change_dashes_to_spaces
    @line = line.gsub("-", " ")
  end

  def remove_commas_and_dots
    @line = line
      .delete(",./*®%")
      .gsub(/\s-/, "")
  end

  def remove_digits
    @line = line.delete("½⅓¼¾⅛⅔⅝⅜⅞").delete("0-9")
  end

  def remove_parentheses
    @line = line
      .gsub(/\(.*?\)/, "")
  end

  def remove_measurements
    MEASUREMENTS.each do |measurement|
      @line = line.gsub(/\b#{measurement}?\b/, "")
    end
  end

  def remove_irregular_measurements
    IRREGULAR_MEASUREMENTS.each do |irregular_measurement|
      @line = line.gsub(/\b#{irregular_measurement}\b/, "")
    end
  end

  def remove_adjectives
    ADJECTIVES.each do |adjective|
      @line = line.gsub(/\b#{adjective}\b/, "")
    end
  end

  def remove_adverbs
    ADVERBS.each do |adverb|
      @line = line.gsub(/\b#{adverb}\b/, "")
    end
  end

  def remove_cooking_methods
    COOKING_METHODS.each do |cooking_method|
      @line = line.gsub(/\b#{cooking_method}\s?/, "")
    end
  end

  def remove_stop_words
    STOP_WORDS.each do |stop_word|
      @line = line.gsub(/\b#{stop_word}\s/, "")
    end
  end

  def remove_sentences
    SENTENCES.each do |sentence|
      @line = line.gsub(/\b#{sentence}/, "")
    end
  end

  def difficult_match
    cream_of_tatar || cream_soup || extra_virgin_olive_oil
  end

  def cream_of_tatar
    match = line.match(/\bcream of tartar\b/)
    match[0] if match
  end

  def cream_soup
    match = line.match(/\bcream of \w+ soup\b/)
    match[0] if match
  end

  def extra_virgin_olive_oil
    match = line.match(/\bextra(\s|-)virgin olive oil\b/)
    match[0] if match
  end
end
