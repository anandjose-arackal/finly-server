# == Schema Information
#
# Table name: admin_review_workflow_levels
#
#  id                       :integer          not null, primary key
#  admin_review_workflow_id :integer          not null
#  position                 :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  trigger_email            :boolean          default(FALSE), not null
#  reviewer                 :boolean          default(FALSE), not null
#  admin_users_id           :integer          not null
#  admin_user_id            :integer          not null
#  email_triggered_at       :datetime
#

class AdminReviewWorkflowLevel < ActiveRecord::Base
  belongs_to :admin_review_workflow
  belongs_to :admin_user

  default_scope { order position: :asc }

  scope :with_admin_user, -> (user_id) { where admin_user_id: user_id }
  scope :with_position, -> (position) { where position: position }
  scope :trigger_email, -> { where trigger_email: true }
  scope :reviewer, -> { where reviewer: true }
  scope :sort_by_email_triggered_at_desc, -> { order email_triggered_at: :desc }
  scope :with_review_workflow, -> (workflow_id) { where admin_review_workflow_id: workflow_id }

end
