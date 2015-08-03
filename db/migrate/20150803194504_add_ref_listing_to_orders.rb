class AddRefListingToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :listing, index: true, foreign_key: true
  end
end
