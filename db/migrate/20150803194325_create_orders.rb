class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.date :start_date
      t.date :end_date
      t.integer :order_price

      t.timestamps null: false
    end
  end
end
