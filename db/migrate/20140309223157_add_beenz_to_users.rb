class AddBeenzToUsers < ActiveRecord::Migration
  def change
    add_column :users, :score, :integer
    add_column :users, :weight, :integer
  end
end
