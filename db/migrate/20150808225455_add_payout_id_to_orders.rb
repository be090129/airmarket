class AddPayoutIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :mangopay_payout_id, :integer
  end
end
