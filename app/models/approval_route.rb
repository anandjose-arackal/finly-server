# == Schema Information
#
# Table name: approval_routes
#
#  id                 :integer          not null, primary key
#  purpose_id         :integer          not null
#  level              :integer          not null
#  reviewer_id        :integer          not null
#  threshold          :integer          default(0), not null
#  created_by_user_id :integer          not null
#  user_id            :integer
#  policy_id          :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class ApprovalRoute < ApplicationRecord
  belongs_to :purpose, optional: true
  belongs_to :user, optional: true
  belongs_to :created_by_user, optional: true, class_name: 'User'
end
