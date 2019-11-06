# == Schema Information
#
# Table name: bbps_bills
#
#  id                   :bigint           not null, primary key
#  subscription_id      :integer
#  user_id              :integer
#  name                 :string(255)
#  sequence_id          :string(255)
#  department_id        :integer
#  cost_center_id       :integer
#  location_id          :integer
#  policy_id            :integer
#  controlling_level_id :integer
#  status_id            :integer
#  amount_id            :integer
#  autofetched          :boolean          default(FALSE)
#  expected_due_date    :date
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  submitted_at         :datetime
#  approved_at          :datetime
#  note                 :text(65535)
#  company_id           :integer
#

class BbpsBill < ApplicationRecord
  include SoftDeletable, Transitionable

  belongs_to :subscription, class_name: 'BbpsBillerSubscription', foreign_key: :subscription_id, optional: true
  belongs_to :department, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :location, class_name: 'BranchLocation', optional: true
  belongs_to :user, class_name: 'User', optional: true
  belongs_to :status, class_name: 'BbpsBillStatus', optional: true
  belongs_to :amount, optional: true

  delegate :open?, :awaiting_approval?, :retracted?, :rejected?, :approved?, :auto_approved?, :payment_ticket_created?, :payment_initiated?, :failed, :paid?, :voided?, to: :status

  scope :filter_status, -> (status) {
    case status
    when 'payables', :payables
      where(status_id: BbpsBill.status_ids(:approved, :auto_approved))
    when 'approved', :approved
      where(status_id: BbpsBillStatus.id_for(:approved))
    when 'auto_approved', :auto_approved
      where(status_id: BbpsBillStatus.id_for(:auto_approved))
    when 'processing', :processing
      where(status_id: BbpsBillStatus.id_for(:awaiting_approval))
    when 'awaiting_approval', :awaiting_approval
      where(status_id: BbpsBillStatus.id_for(:awaiting_approval))
    when 'retracted', :retracted
      where(status_id: BbpsBillStatus.id_for(:retracted))
    when 'rejected', :rejected
      where(status_id: BbpsBillStatus.id_for(:rejected))
    else
      # do nothing
    end
  }

  scope :sort_for_index, -> {
    reorder('bbps_bills.created_at DESC')
  }

  scope :includes_for_index, -> {
    includes(subscription: [:pocs])
  }

  def as_json(options = {})
    {
        id: id,
        biller: subscription.biller.as_json({index: true}),
        # name: name,
        sequence_id: sequence_id,
        department: department.as_json,
        cost_center: cost_center.as_json,
        location: location.as_json,
        policy: policy.as_json,
        # note: note,
        created_at: created_at.strftime("%d-%b-%Y"),
        updated_at: updated_at.strftime("%d-%b-%Y"),
        status: status.as_json,
        user: user&.json_for_trail,
        # biller_category_name: biller_category_name,
        amount: amount.as_json,
        customer_fields: subscription.customer_fields.as_json,
    }
  end

  def self.document_owner_attribute
    'user_id'
  end

  def self.document_status_attribute
    'status_id'
  end

  def self.document_status_class_name
    'BbpsBillStatus'
  end

  def self.roles
    [
        :utility_bill_master_initator,
        :utility_bill_master_reviewer,
        :utility_bill_initator,
        :utility_bill_reviewer,
        :bank_payment_request_initiator,
        :bank_payment_request_reviewer,
        :bank_payment_request_creditor,
        :bank_payment_request_auditor
    ]
  end

  def self.status_ids(*statuses)
    status_ids = []
    statuses.each do |status|
      status_ids.push BbpsBillStatus.id_for(status)
    end

    status_ids.reject {|status_id| status_id.nil?}
  end

  def self.open_statuses
    self.status_ids(:open, :retracted, :rejected)
  end
end
