class AddOrderIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :order_id, :integer
  end
end
