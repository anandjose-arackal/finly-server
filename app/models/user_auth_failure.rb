# == Schema Information
#
# Table name: user_auth_failures
#
#  id         :bigint           not null, primary key
#  user_id    :integer          not null
#  locked     :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ip         :string(255)
#

class UserAuthFailure < ApplicationRecord
  belongs_to :user, optional: true

  scope :within_time, ->(time) {where 'created_at >= ?', time}
end
