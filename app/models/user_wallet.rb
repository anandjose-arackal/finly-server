class UserWallet < ActiveRecord::Base
  belongs_to :user
  belongs_to :balance, class_name: 'Amount'
end