class AddBankAccountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bic, :string
    add_column :users, :iban, :string
  end
end
