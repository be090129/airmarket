class AddMangopayTransactionIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :mangopay_transaction_id, :integer
  end
end
