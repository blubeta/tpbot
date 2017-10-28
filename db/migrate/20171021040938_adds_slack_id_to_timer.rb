class AddsSlackIdToTimer < ActiveRecord::Migration[5.0]
  def change
    add_column :timers, :slack_user_id, :string, nil: false
  end
end
