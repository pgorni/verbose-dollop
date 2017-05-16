class CreateAuthTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :auth_tokens, id: false do |t|
      
      t.string :uuid, limit: 36, primary: true, null: false
      t.string :secret_token

      t.timestamps
    end
  end
end
