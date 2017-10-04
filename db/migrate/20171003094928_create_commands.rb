class CreateCommands < ActiveRecord::Migration[5.0]
  def change
    create_table :commands do |t|
      t.string :name, nil: false
      t.string :description, nil: false
      t.string :usage, nil: false
      t.string :aliases
      t.timestamps
    end
  end
end
