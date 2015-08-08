class AddFeesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :fees_buyer, :integer
    add_column :orders, :fees_seller, :integer
  end
end
