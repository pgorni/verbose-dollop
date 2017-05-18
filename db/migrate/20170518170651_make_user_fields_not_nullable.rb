class MakeUserFieldsNotNullable < ActiveRecord::Migration[5.1]
  def change
  	change_column :users, :name, :string, :null => false
  	change_column :users, :surname, :string, :null => false
  	change_column :users, :hobby, :string, :null => false
  end
end
