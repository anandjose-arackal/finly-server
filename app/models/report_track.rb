# == Schema Information
#
# Table name: report_tracks
#
#  id                        :integer          not null, primary key
#  report_id                 :integer          not null
#  action_user_id            :integer
#  modified_user_id          :integer
#  report_tracking_action_id :integer
#  report_status_id          :integer          not null
#  modified_user_role_id     :integer
#  memo                      :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  payment_id                :integer
#  action_user_role_id       :integer
#  cash_in_hand_deduction_id :integer
#  delegated_action_user_id  :integer
#

class ReportTrack < ApplicationRecord
  belongs_to :report, optional: true
  belongs_to :report_status, optional: true
  belongs_to :tracking_action, optional: true, class_name: 'ReportTrackingAction'
  belongs_to :action_user, optional: true, class_name: 'User'
  belongs_to :action_user_role, optional: true, class_name: 'UserRole'
  belongs_to :modified_user, optional: true, class_name: 'User'
  belongs_to :modified_user_role, optional: true, class_name: 'UserRole'
  belongs_to :payment, optional: true
  belongs_to :cash_in_hand_deduction, optional: true, class_name: 'Payment'
  belongs_to :delegated_action_user, optional: true, class_name: 'User'
  belongs_to :report_tracking_action, optional: true

  default_scope { order('report_tracks.created_at ASC') }

  scope :created_before, ->(time) { where 'created_at < ?', time }
  scope :without_take_control_action, -> { where.not report_tracking_action_id: ReportTrackingAction.id_for(:take_control) }
  scope :manager_role, -> { where('modified_user_role_id = ?', "#{UserRole.id_for(:manager)}") }
  scope :finance_manager_role, -> { where('modified_user_role_id = ?', "#{UserRole.id_for(:finance_manager)}") }
  scope :admin, -> { where('modified_user_role_id = ? OR action_user_role_id = ?', "#{UserRole.id_for(:admin)}", "#{ UserRole.id_for(:admin) }") }
  scope :owner, -> { where('modified_user_role_id = ? OR action_user_role_id = ?', "#{UserRole.id_for(:employee)}", "#{ UserRole.id_for(:employee) }") }
  scope :with_action, ->(action_id) { where report_tracking_action_id: action_id }
  scope :with_action_user_role, ->(role_id) { where action_user_role_id: role_id }
  scope :with_modified_user_role, ->(role_id) { where modified_user_role_id: role_id }
  scope :involving_user, ->(user_id) {where 'action_user_id = ? OR modified_user_id = ?', user_id, user_id }

end
