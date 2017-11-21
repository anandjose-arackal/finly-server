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
  scope :created_before, -> (created_before) {where 'created_at < ?', created_before}
  scope :with_action, -> (action_id) { where action_id: action_id}
  scope :trails_for_approval_chain, -> (bank_payment_request_id) {
    # this scope should essentially just return the approvers and the take control / approve and forward actions
    # first find the latest submit action trail
    latest_submit_trail = self.where(action_id: BankPaymentRequestTrailAction.ids_for([:submit])).reorder(created_at: :desc).first&.id
    # now extract all approvers that are *after* this submit action, including itself
    if latest_submit_trail.present?
      ids = where(action_id: BankPaymentRequestTrailAction.ids_for([:approve, :take_control, :approve_and_forward, :reject, :retract])).where('id >= ?', latest_submit_trail).pluck(:id)
    else
      ids = []
    end
    bpr = BankPaymentRequest.find_by(id: bank_payment_request_id)
    controlling_user_action_ids = where(action_user_id: bpr.controlling_user_id, action_user_role_id: bpr.controlling_user_role_id)
    where(id: ids).where.not(id: controlling_user_action_ids)
  }

  default_scope { order('created_at ASC') }

  def submit_action?
    self.action_id == BankPaymentRequestTrailAction.id_for(:submit)
  end

  def approve_action?
    self.action_id == BankPaymentRequestTrailAction.id_for(:approve)
  end

  def credit_action?
    self.action_id == BankPaymentRequestTrailAction.id_for(:credit)
  end

  def retract_action?
    self.action_id == BankPaymentRequestTrailAction.id_for(:retract)
  end

  def unapprove_action?
    self.action_id == BankPaymentRequestTrailAction.id_for(:unapprove)
  end

  def reject_action?
    self.action_id == BankPaymentRequestTrailAction.id_for(:reject)
  end
end
