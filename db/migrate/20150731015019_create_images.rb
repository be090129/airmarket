class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :caption
      t.integer :listing_id

      t.timestamps null: false
    end
  end
end
