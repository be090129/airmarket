class AddMiseenavantToListings < ActiveRecord::Migration
  def change
    add_column :listings, :miseenavant, :boolean
  end
end
