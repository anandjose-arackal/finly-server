# == Schema Information
#
# Table name: bbps_bills
#
#  id                         :bigint           not null, primary key
#  subscription_id            :integer
#  user_id                    :integer
#  name                       :string(255)
#  sequence_id                :string(255)
#  department_id              :integer
#  cost_center_id             :integer
#  location_id                :integer
#  policy_id                  :integer
#  controlling_level_id       :integer
#  status_id                  :integer
#  amount_id                  :integer
#  autofetched                :boolean          default(FALSE)
#  expected_due_date          :date
#  deleted_at                 :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  submitted_at               :datetime
#  approved_at                :datetime
#  note                       :text(65535)
#  company_id                 :integer
#  category_id                :integer
#  due_date                   :date
#  bill_date                  :date
#  bill_number                :string(255)
#  paid_on_date               :date
#  transaction_id             :string(255)
#  bbps_id                    :string(255)
#  bill_period                :string(255)
#  late_payment_fee_id        :integer
#  early_payment_fee_id       :integer
#  convenience_fee_id         :integer
#  quick_pay                  :string(255)      default("N")
#  total_amount_id            :integer
#  early_payment_fee_selected :boolean          default(FALSE)
#  late_payment_fee_selected  :boolean          default(FALSE)
#  convenience_fee_selected   :boolean          default(FALSE)
#  bbps_biller_id             :integer
#  bill_validation_required   :boolean
#  order_number               :string(255)
#  order_number_type          :string(255)
#  tax_rate_id                :integer
#  hsn_sac                    :string(255)
#  paid_at                    :datetime
#  review_note                :text(65535)
#

class BbpsBill < ApplicationRecord
  include SoftDeletable, Transitionable
  include Sequenced::ActsAsSequenced
  include EventProducer

  acts_as_sequenced column: :sequence_id, purpose: :bbps_bill, editable: false, prefix: 'UB'

  event_channel 'bbps_bill'

  before_save :resolve_bill_validation
  before_save :set_quick_pay

  belongs_to :subscription, class_name: 'BbpsBillerSubscription', foreign_key: :subscription_id, optional: true
  belongs_to :biller, class_name: 'BbpsBiller', foreign_key: :bbps_biller_id, optional: true
  belongs_to :department, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :company, optional: true
  belongs_to :location, class_name: 'BranchLocation', optional: true
  belongs_to :user, class_name: 'User', optional: true
  belongs_to :status, class_name: 'BbpsBillStatus', optional: true
  belongs_to :amount, optional: true
  belongs_to :total_amount, foreign_key: :total_amount_id, class_name: 'Amount', optional: true
  belongs_to :late_payment_fee, foreign_key: :late_payment_fee_id, class_name: 'Amount', optional: true
  belongs_to :early_payment_fee, foreign_key: :early_payment_fee_id, class_name: 'Amount', optional: true
  belongs_to :convenience_fee, foreign_key: :convenience_fee_id, class_name: 'Amount', optional: true

  belongs_to :tax_rate, class_name: 'TaxRate', optional: true
  belongs_to :category, class_name: 'Category', optional: true

  has_many :payments, as: :parent
  has_many :attachments, as: :resource, dependent: :destroy

  accepts_nested_attributes_for :amount

  delegate :open?, :awaiting_approval?, :retracted?, :rejected?, :approved?, :auto_approved?, :payment_ticket_created?, :payment_initiated?, :failed, :paid?, :voided?, :payment_ticket_deleted?, to: :status
  delegate :amount_value, to: :amount

  default_scope {order('bbps_bills.created_at DESC')}

  scope :with_ids, -> (ids) {
    where(id: ids)
  }
  scope :with_id, -> (ids) {
    where(id: ids)
  }

  scope :filter_status, -> (status) {
    case status
    when 'payables', :payables
      where(status_id: BbpsBill.status_ids(:approved, :auto_approved)).joins(:amount).where("amounts.value > ?", 0)
    when 'approved', :approved
      where(status_id: BbpsBillStatus.id_for(:approved))
    when 'auto_approved', :auto_approved
      where(status_id: BbpsBillStatus.id_for(:auto_approved))
    when 'processing', :processing
      where(status_id: BbpsBillStatus.id_for(:awaiting_approval))
    when 'awaiting_approval', :awaiting_approval
      awaiting_action_items(RequestStore.store[:current_user]&.id)
    when 'retracted', :retracted
      where(status_id: BbpsBillStatus.id_for(:retracted))
    when 'rejected', :rejected
      where(status_id: BbpsBillStatus.id_for(:rejected))
    when 'open', :open
      where(status_id: BbpsBillStatus.id_for(:open))
    when 'voided', :voided
      where(status_id: BbpsBillStatus.id_for(:voided))
    when 'paid', :paid
      where(status_id: BbpsBillStatus.id_for(:paid))
    when 'failed', :failed
      where(status_id: BbpsBillStatus.id_for(:failed))
    when 'payment_ticket_created', :payment_ticket_created
      where(status_id: BbpsBillStatus.id_for(:payment_ticket_created))
    when 'payment_initiated', :payment_initiated
      where(status_id: BbpsBillStatus.id_for(:payment_initiated))
    when 'payment_ticket_deleted', :payment_ticket_deleted
      where(status_id: BbpsBillStatus.id_for(:payment_ticket_deleted))
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
    includes(:department, :cost_center, :policy, :location, :user, :status, :tax_rate, :category, amount: [:currency], subscription: [:pocs, :biller])
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
      # where(status_id: BbpsBill.status_ids(:approved, :auto_approved))
      where(status_id: BbpsBill.status_ids(:approved, :auto_approved)).joins(:amount).where("amounts.value > ?", 0)
    end
  }

  scope :filter_biller_id, -> (id) {
    where(bbps_biller_id: id)
  }

  # scope :filter_biller_type, -> (type) {
  #   joins(:biller).where('bbps_billers.biller_category_name = ?', "#{type}")
  # }

  scope :filter_biller_type, -> (biller_type) {
    joins(:biller).where("bbps_billers.biller_category_name = ?", "#{biller_type}")
  }

  scope :filter_poc_id, -> (id) {
    where(user_id: id)
  }

  scope :filter_bill_date, -> (start_date, end_date) {where('bbps_bills.bill_date >= ? AND bbps_bills.bill_date <= ? ', Date.parse(start_date), Date.parse(end_date))}
  scope :filter_due_date, -> (start_date, end_date) {where('bbps_bills.due_date >= ? AND bbps_bills.due_date <= ? ', Date.parse(start_date), Date.parse(end_date))}
  scope :filter_paid_on_date, -> (start_date, end_date) {where('bbps_bills.paid_on_date >= ? AND bbps_bills.paid_on_date <= ? ', Date.parse(start_date), Date.parse(end_date))}
  scope :filter_created_on_date, -> (start_date, end_date) {where("bbps_bills.created_at >= ? AND bbps_bills.created_at <= ?", Date.parse(start_date).beginning_of_day, Date.parse(end_date).end_of_day)}
  scope :filter_approved_on_date, -> (start_date, end_date) {where("bbps_bills.approved_at >= ? AND bbps_bills.approved_at <= ?", Date.parse(start_date).beginning_of_day, Date.parse(end_date).end_of_day)}

  scope :filter_amount, -> (gteq, lteq) do
    gteq = gteq.to_f
    lteq = lteq.present? ? lteq.to_f : 9999999999999999

    joins(:amount).where("value >= ? AND value <= ?", gteq, lteq)
  end

  def as_json(options = {})
    if options[:index]
      data = {
          id: id,
          biller: subscription.biller.as_json({index: true}),
          name: subscription.name,
          sequence_id: sequence_id,
          department: department.as_json,
          cost_center: cost_center.as_json,
          location: location.as_json,
          policy: policy.as_json,
          autofetched: autofetched,
          # note: note,
          created_at: created_at.strftime("%d-%b-%Y"),
          updated_at: updated_at.strftime("%d-%b-%Y"),
          due_date: due_date,
          status: status.as_json,
          pocs: subscription.pocs.as_json,
          # biller_category_name: biller_category_name,
          amount: amount.as_json,
          customer_fields: subscription.all_customer_fields,
      }
      return data
    end

    data = {
        id: id,
        biller: subscription.biller.as_json({index: true}),
        autofetched: autofetched,
        # name: name,
        name: subscription.name,
        sequence_id: sequence_id,
        department: department.as_json,
        cost_center: cost_center.as_json,
        location: location.as_json,
        policy: policy.as_json,
        category: category.as_json,
        tax_rate: tax_rate.as_json,
        hsn_sac: hsn_sac,
        # note: note,
        created_at: created_at.strftime("%d-%b-%Y"),
        updated_at: updated_at.strftime("%d-%b-%Y"),
        status: status.as_json,
        user: user&.json_for_trail,
        payment_ticket_id: self.payments&.first&.payment_order&.bank_payment_request&.id,
        # biller_category_name: biller_category_name,

        amount: amount.as_json,
        total_amount: total_amount.as_json,
        late_payment_fee: late_payment_fee.as_json,
        early_payment_fee: early_payment_fee.as_json,
        convenience_fee: convenience_fee.as_json,

        due_date: due_date,
        bill_date: bill_date,
        bill_period: bill_period,
        bill_number: bill_number,

        late_payment_fee_selected: late_payment_fee_selected,
        early_payment_fee_selected: early_payment_fee_selected,
        convenience_fee_selected: convenience_fee_selected,
        subscription_id: subscription&.id,
        biller_category_name: subscription.biller_category_name,
        mobile_number: subscription.mobile_number,
        customer_fields: subscription.all_customer_fields,
        subscription_pocs: subscription.subscription_pocs.as_json,
        fetch_requirement: subscription.fetch_requirement,
        support_bill_validation: subscription.support_bill_validation,
        auto_generate_bill: subscription.auto_generate_bill,
        expected_bill_day: subscription.expected_bill_day,
        reminder_before_days: subscription.reminder_before_days,
        customer_email: subscription.customer_email,
        customer_name: subscription.customer_name,
        customer_pan: subscription.customer_pan,
        show_payment_details: false,
        attachments: attachments.as_json
    }

    if BbpsBill.status_ids(:paid, :failed).include?(self.status_id)
      data[:show_payment_details] = true
      data[:receipt] = generate_receipt
    end

    data
  end

  def get_default_provider
    if autofetched
      'BbpsBillAutofetchedProvider'
    else
      'BbpsBillNonAutofetchedProvider'
    end
  end

  def generate_receipt
    {
        biller_name: subscription.biller&.biller_name,
        mobile_number: subscription.mobile_number,
        bill_number: bill_number,
        bill_date: bill_date,
        due_date: due_date,
        transaction_ref_id: payments&.first&.bbps_bank_transction&.bbps_ref_id,
        payment_mode: "BSC",
        bill_amount: payments&.first&.amount.as_json,
        transaction_date: paid_at&.strftime("%I:%M %p, %d %b %Y"),
        status: payments&.first&.payment_status&.name
    }
  end

  def bill_validation_required?
    bill_validation_required
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
        :utility_bill_master_initiator,
        :utility_bill_master_reviewer,
        :utility_bill_initiator,
        :utility_bill_reviewer,
        :bank_payment_request_initiator,
        :bank_payment_request_reviewer,
        :bank_payment_request_creditor,
        :bank_payment_request_auditor
    ]
  end

  def self.role_based_initiator_associated_items(user, role_id, options = {})
    if [UserRole.id_for(:utility_bill_initiator)].include?(role_id)
      ids = self.joins(subscription: [:pocs]).where("bbps_bills.company_id = ?", user&.company&.id).where("bbps_subscription_pocs.user_id = ?", user.id).pluck("bbps_bills.id")
      where(id: ids)
    elsif [UserRole.id_for(:utility_bill_master_initiator)].include?(role_id)
      ids = self.joins(:subscription).
          where("bbps_bills.company_id = ?", user&.company&.id).
          where("bbps_biller_subscriptions.user_id = ?", user.id).
          where(autofetched: true).
          or(
              self.joins(:subscription).
                  where("bbps_bills.company_id = ?", user&.company&.id).
                  where("bbps_biller_subscriptions.user_id = ?", user.id).
                  where(autofetched: false).
                  where.not(status_id: BbpsBillStatus.id_for(:open))
          ).pluck("bbps_bills.id")
      where(id: ids)
    elsif role_id == UserRole.id_for(:bank_payment_request_initiator)
      role_based_creditor_associated_items(user, role_id)
    end
  end

  def self.role_based_reviewer_associated_items(user, role_id, options = {})
    policy_ids = user.policy_user_roles.where(user_role_id: role_id).pluck(:policy_id).uniq rescue nil

    if role_id == UserRole.id_for(:utility_bill_reviewer)
      super
    elsif UserRole.id_for(:utility_bill_master_reviewer)
      subscription_ids = BbpsBillerSubscription.role_based_reviewer_associated_items(user, role_id).pluck(:id)
      ids = self.joins(:subscription).
          where("bbps_biller_subscriptions.id in (?)", subscription_ids).where("bbps_bills.autofetched = ?", true).or(
                  self.joins(:subscription).where("bbps_biller_subscriptions.id in (?)", subscription_ids).where("bbps_bills.autofetched = ?" , false).where.not("bbps_bills.status_id = ?", BbpsBillStatus.id_for(:open))
      ).pluck("bbps_bills.id")
      where(id: ids)
    elsif UserRole.id_for(:bank_payment_request_reviewer)
      role_based_creditor_associated_items(user, role_id)
    end
  end

  def self.role_based_associated_status_ids(user)
    self.status_ids(*self.role_based_statuses(user))
    # PurchaseOrderStatus.ids_for(*self.role_based_statuses(user))
  end

  def self.open_status_ids(user)
    BbpsBillStatus.ids_for(:open)
  end

  def self.role_based_statuses(user)
    statuses = []
    if user.policy_user_roles.pluck(:user_role_id).uniq.present?
      user.policy_user_roles.pluck(:user_role_id).uniq.each do |role_id|
        if UserRole.ids_for(:bank_payment_request_initiator, :bank_payment_request_reviewer, :bank_payment_request_auditor, :bank_payment_request_creditor).include?(role_id.to_i)
          statuses += [:approved, :auto_approved, :payment_ticket_created, :payment_initiated, :failed, :paid, :voided, :payment_ticket_deleted]
        elsif UserRole.ids_for(:utility_bill_master_initiator, :utility_bill_master_reviewer, :utility_bill_initiator, :utility_bill_reviewer).include?(role_id.to_i)
          statuses += [:open, :awaiting_approval, :retracted, :rejected, :approved, :auto_approved, :payment_ticket_created, :payment_initiated, :failed, :paid, :voided, :payment_ticket_deleted]
        elsif UserRole.id_for(:admin) == role_id.to_i
          statuses += [:open, :awaiting_approval, :retracted, :rejected, :approved, :auto_approved, :payment_ticket_created, :payment_initiated, :failed, :paid, :voided, :payment_ticket_deleted]
        end
      end
    end
    return statuses.uniq
  end

  def self.finance_associated_status_ids
    BbpsBill.status_ids(:approved, :auto_approved, :payment_ticket_created, :payment_initiated, :failed, :paid, :voided, :payment_ticket_deleted)
  end

  def self.auditor_associated_status_ids
    self.status_ids(:open, :rejected, :retracted, :awaiting_approval, :approved, :auto_approved, :payment_ticket_created, :payment_initiated, :failed, :paid, :voided, :payment_ticket_deleted)
  end

  def self.status_ids(*statuses)
    BbpsBillStatus.ids_for(statuses)
  end

  def self.open_statuses
    self.status_ids(:open, :retracted, :rejected)
  end

  def self.human_name(options = {})
    options[:plural] ? 'Utility Bills' : 'Utility Bill'
  end

  def payable?
    BbpsBillStatus.ids_for(:approved, :auto_approved).include?(self.status_id)
  end

  private

  def resolve_bill_validation
    if self.amount.present? && self.amount.changes.keys.include?("value") && self.biller.present? && (self.biller.support_bill_validation == "MANDATORY" || self.biller.support_bill_validation == "OPTIONAL")
      self.bill_validation_required = true
    end
  end

  # this methid will set the quickpay attribute based on a
  # bunch of parameters that are present in the biller
  def set_quick_pay
    type = self.biller&.biller_mode
    ad_hoc = self.biller&.biller_accepts_adhoc
    fetch_requirement = self.biller&.fetch_requirement
    validation_support = self.biller&.support_bill_validation
    if (fetch_requirement == "NOT_SUPPORTED") && (validation_support == "NOT_SUPPORTED")
      self.quick_pay = "Y"
    end
  end

end
