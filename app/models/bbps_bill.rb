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
#  category_id          :integer
#  due_date             :date
#  bill_date            :date
#  bill_number          :string(255)
#  paid_on_date         :date
#  transaction_id       :string(255)
#  bbps_id              :string(255)
#  bill_period          :string(255)
#  late_payment_fee_id  :integer
#  fixed_charge_id      :integer
#  additional_charge_id :integer
#  quick_pay            :boolean          default(TRUE)
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

  accepts_nested_attributes_for :amount

  delegate :open?, :awaiting_approval?, :retracted?, :rejected?, :approved?, :auto_approved?, :payment_ticket_created?, :payment_initiated?, :failed, :paid?, :voided?, to: :status
  delegate :amount_value, to: :amount

  default_scope {order('bbps_bills.created_at DESC')}

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

  scope :with_id, -> (id) {
    where id: id
  }

  scope :sort_for_index, -> {
    reorder('bbps_bills.created_at DESC')
  }

  scope :includes_for_index, -> {
    includes(subscription: [:pocs])
  }

  scope :filter_department_id, -> (id) {
    where(department_id: id)
  }

  scope :filter_cost_center_id, -> (id) {
    where(cost_center_id: id)
  }

  scope :filter_policy_id, -> (id) {
    where(policy_id: id)
  }

  scope :filter_location_id, -> (id) {
    where(location_id: id)
  }

  scope :filter_subscription_id, -> (id) {
    where(subscription_id: id)
  }

  scope :filter_payable_bills, -> (enabled) {
    if enabled
      where(status_id: BbpsBill.status_ids(:approved, :auto_approved))
    end
  }

  def as_json(options = {})
    if options[:index]
      data = {
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
      return data
    end

    {
        id: id,
        biller: subscription.biller.as_json,
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

  def self.role_based_initiator_associated_items(user, role_id, options = {})
    if [UserRole.id_for(:utility_bill_initator)].include?(role_id)
      user.send("#{self.table_name}")
    elsif role_id == UserRole.id_for(:bank_payment_request_initiator)
      policy_ids = PolicyUserRole.where(user_id: user.id, user_role_id: role_id).pluck(:policy_id)
      user.company.send("#{self.table_name}").where(policy_id: policy_ids, invoice_status_id: finance_associated_status_ids)
    end
  end

  def self.finance_associated_status_ids
    BbpsBill.status_ids %i( approved auto_approved payment_ticket_created payment_initiated failed paid voided )
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

  def payable?
    BbpsBillStatus.ids_for(:approved, :auto_approved).include?(self.status_id)
  end
end
