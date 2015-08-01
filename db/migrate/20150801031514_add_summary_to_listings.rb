class AddSummaryToListings < ActiveRecord::Migration
  def change
    add_column :listings, :summary, :string
  end
end
