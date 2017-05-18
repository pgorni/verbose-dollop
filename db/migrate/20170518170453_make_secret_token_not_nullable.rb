class MakeSecretTokenNotNullable < ActiveRecord::Migration[5.1]
  def change
  	change_column :auth_tokens, :secret_token, :string, :null => false
  end
end
