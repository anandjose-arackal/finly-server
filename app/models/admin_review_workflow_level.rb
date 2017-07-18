# == Schema Information
#
# Table name: admin_review_workflow_levels
#
#  id                       :integer          not null, primary key
#  admin_review_workflow_id :integer          not null
#  position                 :integer          not null
#  admin_reviewer_id        :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class AdminReviewWorkflowLevel < ActiveRecord::Base
  belongs_to :admin_review_workflow
  belongs_to :admin_reviewer, class_name: 'AdminUser'

  default_scope { order position: :asc }

  scope :with_admin_reviewer, -> (reviewer_id) { where admin_reviewer_id: reviewer_id }
  scope :with_position, -> (position) { where position: position }

end
