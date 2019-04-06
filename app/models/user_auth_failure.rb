# == Schema Information
#
# Table name: user_auth_failures
#
#  id         :bigint(8)        not null, primary key
#  user_id    :integer          not null
#  locked     :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserAuthFailure < ApplicationRecord
  belongs_to :user

  scope :within_time, ->(time) {where 'created_at >= ?', time}
end
