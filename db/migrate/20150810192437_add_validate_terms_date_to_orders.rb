class AddValidateTermsDateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :validate_terms_date, :datetime
  end
end
