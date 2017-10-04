class AddsPausedToTimer < ActiveRecord::Migration[5.0]
  def change
    add_column :timers, :paused, :boolean, default: false
    add_column :timers, :paused_time, :decimal, precision: 4, scale: 2, default: 0.0
  end
end
