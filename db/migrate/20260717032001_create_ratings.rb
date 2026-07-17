class CreateRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :ratings do |t|
      t.decimal :rating, precision: 2, scale: 1
      t.references :blog, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :ratings, [ :blog_id, :user_id ], unique: true
  end
end
