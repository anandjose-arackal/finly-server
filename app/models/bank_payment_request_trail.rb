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
#  action_for_user_id      :integer
#  action_for_user_role_id :integer
#

class BankPaymentRequestTrail < ApplicationRecord

  attr_accessor :excluded_id_ranges

  belongs_to :bank_payment_request, optional: true
  belongs_to :action_user, optional: true, class_name: "User"
  belongs_to :modified_user, optional: true, class_name: "User"
  belongs_to :action_user_role, optional: true, class_name: "UserRole"
  belongs_to :modified_user_role, optional: true, class_name: "UserRole"
  belongs_to :action, optional: true, class_name: "BankPaymentRequestTrailAction"

  scope :without_id, -> (id) { where.not id: id }
  scope :manager_role, -> { where('modified_user_role_id = ?', "#{UserRole.id_for(:manager)}") }
  scope :finance_manager_role, -> { where('modified_user_role_id = ?', "#{UserRole.id_for(:finance_manager)}") }
  scope :involving_user, -> (user_id) { where('modified_user_id = ? OR action_user_id = ?', user_id, user_id) }
  scope :created_before, -> (created_before) {where 'created_at < ?', created_before}
  scope :with_action, -> (action_id) { where action_id: action_id }
  scope :with_action_user, -> (action_user_id) {
    where action_user_id: action_user_id
  }
  scope :with_action_user_role, ->(role_id) { where action_user_role_id: role_id }
  scope :trails_for_approval_chain, -> {
    # this scope should essentially just return the approvers and the take control / approve and forward actions
    # first find the latest submit action trail
    latest_submit_trail = self.where(action_id: BankPaymentRequestTrailAction.ids_for([:submit])).reorder(created_at: :desc).first&.id
    # now extract all approvers that are *after* this submit action, including itself
    if latest_submit_trail.present?
      ids = where('id >= ?', latest_submit_trail).pluck(:id)
    else
      ids = self.pluck(:id)
    end
    where(id: ids)
  }
  scope :with_action_user_and_role, -> (user_id, role_id, action_id) {
    where(action_user_id: user_id, action_user_role_id: role_id, action_id: action_id)
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

  private

end
