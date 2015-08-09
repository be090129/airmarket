class AddValidatedTimeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :validated_time, :datetime
  end
end
