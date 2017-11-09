class User < ApplicationRecord
  enum level: ["non_senior", "senior"]
end
