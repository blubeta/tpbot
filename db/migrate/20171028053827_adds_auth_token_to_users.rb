class AddsAuthTokenToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :tp_auth_token, :string
  end
end
