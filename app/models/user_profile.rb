class UserProfile < ActiveRecord::Base
  belongs_to :user
  belongs_to :default_currency, class_name: "Currency"

  has_attached_file :avatar, styles: {large: "2160x2160>", normal: "1080x1080>", thumb: "500x500>"}

  validates :user_id, presence: true
end
