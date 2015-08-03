class AddStandardPriceToListings < ActiveRecord::Migration
  def change
    add_column :listings, :listing_price_standard, :integer
  end
end
