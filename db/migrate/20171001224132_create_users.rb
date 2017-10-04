class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name
      t.integer :tp_user_id, null: false
      t.integer :harvest_user_id, null: false
      t.timestamps
    end
  end
end
