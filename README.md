# Recipe search app

This repo contains an app allowing users to search for recipes containing different ingredients they want to be included in the recipes.

```
Ruby: 3.3.5
Rails: 7.2.2
PostgerSQL
```

### Run app locally
```
bin/setup
bin/dev
```
### Run specs and linting
```
COVERAGE=true bundle exec rspec
bin/rake standard
```  

The app is available for testing at [https://recipe-search-app-sparkling-paper-3306.fly.dev/](https://recipe-search-app-sparkling-paper-3306.fly.dev/)

## Scenario 1 User inputs ingredients and finds a recipe

**Context**: User has some `tomatoes` how which are about to go bad soon, so they want to cook a meal out of them. Besides this they are also have `butter`, `onions`, `pasta`, etc. However the user is about to go on a date in the evening, so they really want to avoid using `garlic`.

**Actions**:
1. User opens the app
2. User clicks on the "Add a required ingredient" button.
3. User writes `tomatoes` into the search bar and clicks on the tomatoes result tag, showing that there are 729 recipes with tomatoes.
4. The tag shows up at the top of the page in dark green to indicate required ingredient.
5. User click on the the "Add an excluded ingredient" button.
6. User writes `garlic` into the search bar, and chooses garlic tag.
7. The tag shows up at the top of the page in dark red to indicate excluded ingredient.
8. User continues to add `parmesan cheese` and `butter` to optional ingredients, which show up in light green to indicate optional ingredients.
9. User browses through the returned recipes, and click next to show up the next page of results.
10. User decides on the recipe and clicks on it to reveal the details


## Scenario 2 User inputs two many ingredients and needs to refine the search
**Context**: User is feeling creative, and has bought beets and is now looking for a creative recipe that combines unexpected ingredients.

**Actions**:
1. User opens the app
2. User clicks on the "Add a required ingredient" button.
3. User writes `beets` into the search bar and clicks on the beets result tag, showing that there are 25 recipes with beets.
4. The tag shows up at the top of the page in dark green to indicate required ingredient.
5. User writes `cumin` into the search bar and clicks on the cumin result tag.
6. The tag shows up at the top of the page in dark green to indicate required ingredient.
7. However there are now 0 recipes, so user clicks on the light red cross icon next to cuming tag.
8. The cumin tag has now been removed from the top of the page and there are 25 recipes showing again.
9. This time user adds `kalamata olives`, `butter` and `onions` as a optional ingredients.
10. The first recipe is the one with the most matching ingredients across all ingredients and the best ranking, so user chooses Vegetarian Borscht.

## Future features
This demo app focuses on the ingredient search part.

To make the searching better, more functionalities that could be added, like:
* narrow down by cooking time
* narrow down by number of total ingredients in the recipe
* narrow down by ranking
* searching for categories
* finding more recipes from the same author
* narrowing down future searchable ingredients with regards to the ingredients already chosen (to avoid null search results)
* tracking which recipes get opened most often and prioritizing those in the search results or suggesting them
* use a slug url for the show recipe page
* refine the tag extractor more
