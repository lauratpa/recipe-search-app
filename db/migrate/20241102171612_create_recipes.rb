class CreateRecipes < ActiveRecord::Migration[7.2]
  def change
    create_table :recipes do |t|
      t.text :title, null: false
      t.integer :cook_time, null: false
      t.integer :prep_time, null: false
      t.text :author, null: false
      t.text :image_url, null: false
      t.float :rating, null: false
      t.jsonb :details, null: false, default: []
      t.integer :category_id, null: false

      t.timestamps
    end
  end
end
