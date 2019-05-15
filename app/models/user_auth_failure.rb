# == Schema Information
#
# Table name: user_auth_failures
#
#  id               :bigint           not null, primary key
#  user_id          :integer
#  locked           :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  ip               :string(255)
#  username         :string(255)
#  blank_username   :boolean          default(FALSE)
#  blank_password   :boolean          default(FALSE)
#  invalid_username :boolean          default(FALSE)
#  invalid_password :boolean          default(FALSE)
#

class UserAuthFailure < ApplicationRecord
  belongs_to :user, optional: true

  scope :within_time, ->(time) {where 'created_at >= ?', time}
end
