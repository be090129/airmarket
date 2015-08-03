class AddInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :adressline1, :string
    add_column :users, :city, :string
    add_column :users, :region, :string
    add_column :users, :postalcode, :string
    add_column :users, :country, :string
    add_column :users, :nationality, :string
    add_column :users, :birthday, :date
  end
end
