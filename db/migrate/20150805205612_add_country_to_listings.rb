class AddCountryToListings < ActiveRecord::Migration
  def change
    add_column :listings, :country, :string
  end
end
