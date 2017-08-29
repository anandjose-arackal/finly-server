# == Schema Information
#
# Table name: bank_payment_request_trails
#
#  id                      :integer          not null, primary key
#  bank_payment_request_id :integer
#  request_status_id       :integer
#  action_user_id          :integer
#  action_user_role_id     :integer
#  modified_user_id        :integer
#  modified_user_role_id   :integer
#  action_id               :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class BankPaymentRequestTrail < ActiveRecord::Base
  belongs_to :bank_payment_request
  belongs_to :action_user, class_name: "User"
  belongs_to :modified_user, class_name: "User"
  belongs_to :action_user_role, class_name: "UserRole"
  belongs_to :modified_user_role, class_name: "UserRole"
  belongs_to :action, class_name: "BankPaymentRequestTrailAction"

  scope :manager_role, -> { where('modified_user_role_id = ?', "#{UserRole.id_for(:manager)}") }
  scope :finance_manager_role, -> { where('modified_user_role_id = ?', "#{UserRole.id_for(:finance_manager)}") }
  scope :involving_user, -> (user_id) { where('modified_user_id = ? OR action_user_id = ?', user_id, user_id) }
  scope :Created_before, -> (created_before) {where 'created_at < ?', created_before}
end
