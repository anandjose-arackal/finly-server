# == Schema Information
#
# Table name: card_load_request_tracks
#
#  id                           :integer          not null, primary key
#  card_load_request_id         :integer          not null
#  action_user_id               :integer
#  card_load_tracking_action_id :integer
#  status_id                    :integer
#  user_request_role_id         :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

class CardLoadRequestTrack < ActiveRecord::Base

  belongs_to :card_load_request
  belongs_to :action_user, class_name: 'User'
  belongs_to :card_load_request_action
  belongs_to :status, class_name: 'CardLoadRequestStatus'
  belongs_to :user_request_role, class_name: 'UserRole'

  default_scope { order('created_at ASC') }

  scope :created_before, ->(time) { where 'created_at < ?', time }
  scope :without_take_control_action, -> { where.not card_load_request_action_id: CardLoadTrackingAction.take_control_id }
  scope :manager_role, -> { where user_report_role_id: UserRole.manager_id }
  scope :finance_manager_role, -> { where user_request_role_id: UserRole.finance_manager_id }
  scope :admin, -> { where user_report_role_id: UserRole.admin_id }
  scope :owner, -> { where user_report_role_id: UserRole.employee_id }
  scope :with_action, ->(action_id) { where card_load_request_action_id: action_id }

end
