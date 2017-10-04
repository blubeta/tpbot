class Timer < ApplicationRecord
  validates :tp_user_id, presence: true
  validates :harvest_user_id, presence: true
end
