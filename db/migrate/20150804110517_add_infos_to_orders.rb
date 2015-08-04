class AddInfosToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :status, :string
    add_column :orders, :message, :text
  end
end
