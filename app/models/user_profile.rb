class UserProfile < ActiveRecord::Base
  belongs_to :user
  belongs_to :default_currency, class_name: "Currency"
end
