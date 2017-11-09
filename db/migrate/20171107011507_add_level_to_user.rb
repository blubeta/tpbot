class AddLevelToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :level, :integer
  end
end
