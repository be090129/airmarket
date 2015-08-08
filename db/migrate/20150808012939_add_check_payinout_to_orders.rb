class AddCheckPayinoutToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :check_payin, :boolean
    add_column :orders, :check_payout, :boolean
  end
end
