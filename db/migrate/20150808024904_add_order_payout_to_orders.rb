class AddOrderPayoutToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_payout, :integer
  end
end
