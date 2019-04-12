
class User < ActiveRecord::Base
  has_many :trackers

  validates :slack_team_id, presence: true, uniqueness: true
  validates :slack_user_id, presence: true, uniqueness: true
end