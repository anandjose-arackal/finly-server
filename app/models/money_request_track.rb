# == Schema Information
#
# Table name: money_request_tracks
#
#  id                               :integer          not null, primary key
#  money_request_id                 :integer          not null
#  action_user_id                   :integer
#  modified_user_id                 :integer
#  money_request_tracking_action_id :integer
#  status_id                        :integer
#  modified_user_role_id            :integer
#  payment_id                       :integer
#  memo                             :string(255)
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  action_id                        :integer
#  action_user_role_id              :integer
#






class MoneyRequestTrack < ActiveRecord::Base

  belongs_to :money_request
  belongs_to :action_user, class_name: 'User'
  belongs_to :modified_user, class_name: 'User'
  belongs_to :money_request_action
  belongs_to :status, class_name: 'MoneyRequestStatus'
  belongs_to :action_user_role, class_name: 'UserRole'
  belongs_to :modified_user_role, class_name: 'UserRole'
  belongs_to :payment

  default_scope { order('created_at ASC') }

  scope :created_before, ->(time) { where 'created_at < ?', time }
  scope :without_take_control_action, -> { where.not money_request_tracking_action_id: MoneyRequestTrackingAction.id_for(:take_control) }
  scope :manager_role, -> { where('modified_user_role_id = ?', "#{UserRole.id_for(:manager)}") }
  scope :finance_manager_role, -> { where('modified_user_role_id = ?', "#{UserRole.id_for(:finance_manager)}") }
  scope :admin, -> { where('modified_user_role_id = ? OR action_user_role_id = ?', "#{UserRole.id_for(:admin)}", "#{ UserRole.id_for(:admin) }") }
  scope :owner, -> { where('modified_user_role_id = ? OR action_user_role_id = ?', "#{UserRole.id_for(:employee)}", "#{ UserRole.id_for(:employee) }") }
  scope :with_action, ->(action_id) { where money_request_tracking_action_id: action_id }
  scope :with_action_user, ->(action_user_id) {where action_user_id: action_user_id}
  scope :involving_user, ->(user_id) {where 'action_user_id = ? OR modified_user_id = ?', user_id, user_id }
  scope :with_modified_user, -> (user_id) {where modified_user_id: user_id}

end
