class CreateTimers < ActiveRecord::Migration[5.0]
  def change
    create_table :timers do |t|
      t.decimal :hours,   precision: 4, scale: 2, default: 0.0
      t.boolean :running, default: true
      t.string :tp_card_id, null: false
      t.string :tp_user_id, null: false
      t.string :harvest_user_id, null: false
      t.timestamps
    end
  end
end
