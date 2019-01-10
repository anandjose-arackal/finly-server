# == Schema Information
#
# Table name: bank_payment_requests
#
#  id                           :integer          not null, primary key
#  owner_id                     :integer
#  status_id                    :integer
#  controlling_user_id          :integer
#  payment_order_id             :integer
#  name                         :string(255)
#  requested_amount_id          :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  submitted_at                 :datetime
#  controlling_user_role_id     :integer
#  description                  :text(65535)
#  controlling_for_user_id      :integer
#  controlling_for_user_role_id :integer
#  require_approval             :boolean
#  is_deleted                   :boolean
#  beneficiary_type_id          :integer
#  policy_id                    :integer
#  payment_file_downloaded      :boolean          default(FALSE)
#  auto_approved                :boolean
#  api_initiated                :boolean          default(FALSE)
#  controlling_level_id         :integer
#

class BankPaymentRequest < ActiveRecord::Base

  include SoftDeletable,
          FindByOrderedIds,
          Transitionable

  belongs_to :status, class_name: "BankPaymentRequestStatus"
  belongs_to :payment_order, dependent: :destroy
  belongs_to :requested_amount, class_name: "Amount"
  belongs_to :owner, class_name: "User"
  belongs_to :controlling_user, class_name: "User"
  belongs_to :controlling_user_role, class_name: "UserRole"
  belongs_to :controlling_for_user, class_name: "User"
  belongs_to :controlling_for_user_role, class_name: "UserRole"
  belongs_to :policy

  has_many :comments, class_name: "BankPaymentRequestComment"
  has_many :bank_payment_request_trails

  accepts_nested_attributes_for :payment_order
  accepts_nested_attributes_for :requested_amount

  # i.e. a payment request cannot exist without a payment order
  validates :payment_order, presence: true

  default_scope {order(created_at: :desc)}

  delegate :open?, :submitted?, :retracted?, :rejected?, :approved?, :credited?, :processing?, to: :status
  # delegate :requested_amount_value, to: :requested_amount
  delegate :scheduled?, to: :payment_order

  scope :non_owner, -> (user_id) {where.not owner_id: user_id}
  scope :with_controlling_user, -> (user_id) {where controlling_user_id: user_id}
  scope :with_controlling_user_role, -> (role_id) {where controlling_user_role_id: role_id}
  scope :with_user, -> (user_id) {where owner_id: user_id}
  scope :with_budgetable_user_ids, -> (user_ids) {
    if user_ids.present?
      where(owner_id: user_ids)
    end
  }

  scope :not_open, -> {where.not status_id: BankPaymentRequestStatus.id_for(:open)}
  scope :with_id, -> (id) {where id: id}
  scope :without_id, -> (id) {where.not id: id}
  scope :approved, -> {where status_id: BankPaymentRequestStatus.id_for(:approved)}
  scope :filter_status_id, -> (status_id) {
    case status_id
    when 1, '1' # i.e. open
      where status_id: BankPaymentRequestStatus.id_for(:open)
    when 2, '2' # i.e. processing
      where status_id: BankPaymentRequestStatus.id_for(:processing)
    when 3, '3' # i.e. retracted
      where status_id: BankPaymentRequestStatus.id_for(:retracted)
    when 4, '4' # i.e. rejected
      where status_id: BankPaymentRequestStatus.id_for(:rejected)
    when 5, '5' # i.e. approved
      where status_id: BankPaymentRequestStatus.id_for(:approved)
    when 6, '6' # i.e. credited
      where status_id: BankPaymentRequestStatus.id_for(:credited)
    when 7, '7' # i.e. failed
      joins(:payment_order).where('payment_orders.payment_order_status_id = ?', PaymentOrderStatus.id_for(:failed))
    when 8, '8' # i.e. scheduled
      joins(:payment_order).where('payment_orders.payment_order_status_id = ?', PaymentOrderStatus.id_for(:scheduled))
    when 9, '9' # i.e. pending
      joins(:payment_order).where('payment_orders.payment_order_status_id = ?', PaymentOrderStatus.id_for(:pending))
    when '10', 10 # i.e awaiting approval from current user
      case UserRole.id_for(RequestStore.store[:params]&.dig(:view)&.to_sym)
      when UserRole.id_for(:admin)
        where(controlling_user_id: RequestStore.store[:current_user]&.id, status_id: BankPaymentRequestStatus.id_for(:processing))
      else
        where(controlling_user_id: RequestStore.store[:current_user]&.id, status_id: BankPaymentRequestStatus.id_for(:processing), controlling_user_role_id: UserRole.id_for(RequestStore.store[:params]&.dig(:view)&.to_sym))
      end
    else
      # do nothing?
    end
  }

  scope :order_by_controlling_user, ->(user_id, manager = false) {
    if user_id.present?
      ids = pluck(:id)
      controlling_requests = where(controlling_user_id: user_id)
      if manager
        controlling_requests = controlling_requests.where(status_id: BankPaymentRequestStatus.id_for(:processing))
      end
      controlling_ids = controlling_requests.pluck(:id)
      ordered_ids = controlling_ids + (ids - controlling_ids)
      find_ordered(ordered_ids)
    end
  }

  scope :order_by, ->(type, user_id = nil) {
    case type
    when :created_at
      reorder(created_at: :desc)
    when :manager_controlling_user
      order_by_controlling_user(user_id, true)
    when :controlling_user
      order_by_controlling_user(user_id)
    when :submitted_at
      reorder(submitted_at: :desc)
    end
  }

  scope :include_for_index, -> {includes({payment_order: [:payment_order_status, :initiating_user,
                                                          {payments: [
                                                              {amount: [:currency]},
                                                              {receiving_account: :account_owner}, :payment_status, :reference_resource,
                                                              :invoice,
                                                              {payment_order: [bank_payment_request: [:status]]},
                                                              :payment_order]},
                                                              {amount_processed: [:currency]}, {amount_requested: [:currency]}]}, :status, :controlling_user)}
  scope :include_for_data_retrieval, -> {includes(payment_order: {payments: [{receiving_account: :account_owner},
                                                                             :initiating_user,
                                                                             {payment_order: [bank_payment_request: [:status, :controlling_user]]},
                                                                             {invoice: [:amount, :discount_amount, :tax_amount, :tds_amount, :advance_amount]},
                                                                             :amount]})}

  scope :filter_date, -> (date_from, date_to) {
    date_from = "1990-01-01" if date_from.blank?
    date_to = DateUtils.local_date.strftime("%d-%m-%Y") if date_to.blank?
    date_from = DateTime.parse(date_from).beginning_of_day unless date_from.is_a?(Date)
    date_to = DateTime.parse(date_to).end_of_day unless date_to.is_a?(Date)
    joins(:payment_order).where('payment_orders.created_at >= ? AND payment_orders.created_at <= ?', date_from, date_to)
  }

  scope :filter_scheduled_date, -> (date_from, date_to) {
    date_from = "1990-01-01" if date_from.blank?
    date_to = DateUtils.local_date.strftime("%d-%m-%Y") if date_to.blank?
    date_from = DateTime.parse(date_from).beginning_of_day unless date_from.is_a?(Date)
    date_to = DateTime.parse(date_to).end_of_day unless date_to.is_a?(Date)
    joins(:payment_order).where('payment_orders.scheduled_at >= ? AND payment_orders.scheduled_at <= ?', date_from, date_to)
  }

  scope :filter_controlling_user, -> (user_id) {where controlling_user_id: user_id}

  scope :processing, -> {where status_id: BankPaymentRequestStatus.id_for(:processing)}

  scope :includes_details, -> {includes(:status, :owner, :requested_amount)}

  scope :include_attachments, -> {includes(payment_order: [:payment_order_attachments, payments: [invoice: [:invoice_attachments]]])}

  scope :filter_custom_drop_down_selection, -> (drop_down_item_id) {
    drop_down_selection_ids = FieldDropDownSelection.with_value(drop_down_item_id).pluck(:id)
    multiselect_item_ids = FieldMultiselectItem.where(id: drop_down_item_id).pluck(:id)
    raw_po_ids = self.pluck(:payment_order_id)
    raw_invoice_ids = Payment.where(payment_order_id: raw_po_ids).pluck(:invoice_id)
    # raw_invoice_ids = Invoice.where(payment_id: raw_payment_ids)
    invoice_ids = CustomField.with_drop_down_selection(drop_down_selection_ids).with_parent(raw_invoice_ids, "Invoice").pluck(:parent_id)
    invoice_ids += CustomField.with_multi_select_selection(multiselect_item_ids).with_parent(raw_invoice_ids, "Invoice").pluck(:parent_id)
    po_ids = Payment.where(invoice_id: invoice_ids).pluck(:payment_order_id)
    bpr_ids = BankPaymentRequest.where(payment_order_id: po_ids).pluck(:id)
    where(id: bpr_ids)
  }

  scope :filter_policy_id, -> (policy_id) {
    where policy_id: policy_id
  }

  scope :filter_owner_id, -> (owner_id) {
    where owner_id: owner_id
  }

  scope :filter_user_id, -> (owner_id) {
    where owner_id: owner_id
  }

  scope :non_approved, -> {where.not(status_id: BankPaymentRequestStatus.id_for(:approved))}
  scope :creditable, -> {where status_id: BankPaymentRequestStatus.ids_for(:approved)}

  scope :filter_payment_ids, -> (payment_ids) {
    payment_ids = payment_ids.split(",").each {|e| e.strip!}
    all_payments = Payment.where(payment_order_id: self.pluck(:payment_order_id))
    payment_order_ids = all_payments.where(id: payment_ids).pluck(:payment_order_id)
    where(payment_order_id: payment_order_ids)
  }

  scope :filter_vendor_id, -> (vendor_id) {
    payment_order_ids = self.pluck(:payment_order_id)
    payments = Payment.where(payment_order_id: payment_order_ids)
    payment_order_ids = payments.where(receiving_user_type: "YesBankVendor", receiving_user_id: vendor_id).pluck(:payment_order_id)
    where(payment_order_id: payment_order_ids)
  }

  attr_accessor :cache_users

  before_save do
    if self.name.blank?
      self.name = generate_name
    end
  end

  def can_submit?
    open? || retracted? || rejected?
  end

  def can_approve?
    processing?
  end

  def can_reject?
    processing?
  end

  def can_retract?
    processing? || auto_approved?
  end

  def can_credit?
    approved?
  end

  def can_take_control?
    processing?
  end

  # def can_return_control?
  #   processing?
  # end

  def credit_pending?
    approved? && !credited?
  end

  def pending?
    self.status_id == BankPaymentRequestStatus.id_for(:pending)
  end

  def auto_approved?
    # extracting the last tracks and checking if it was a submit action combined
    # with the next action user being blank
    trail = self.bank_payment_request_trails.last
    (trail.submit_action? && trail.modified_user.blank?) || self.auto_approved
  end

  def user
    self.owner
  end

  def initiating_account
    self.payment_order.payments.first.initiating_account
  end

  def initiating_account_name
    self.payment_order.payments.first.initiating_account_type_name
  end

  def status_name(user_id)
    if self.status_id == BankPaymentRequestStatus.id_for(:processing)
      if user_id == self.controlling_user_id
        return "awaiting_approval"
      else
        return "processing"
      end
    end
    if [BankPaymentRequestStatus.id_for(:credited)].include?(self.status_id)
      return self.payment_order.payment_order_status&.name
    elsif [BankPaymentRequestStatus.id_for(:approved)].include?(self.status_id)
      return "pending_credit"
    end
    self.status&.name&.to_s
  end

  def beneficiary_type
    case self.payment_order.payments.first&.receiving_user&.class&.name
    when "User"
      return 1 # i.e. 1 is users
    when "YesBankVendor"
      return 2 # i.e. 2 is vendors
    else
      return 2 # i.e. it's vendors by default
    end
  end

  def total_amount
    self.requested_amount.value
  end

  def payment_mode
    self.payment_order.payment_mode
  end

  def retriable?
    self.payment_order.partially_completed? || self.payment_order.failed?
  end

  def verified?
    [BankPaymentRequestStatus.ids_for([:approved, :credited])].include?(self.status_id)
  end

  def credit_card?
    self.payment_order.payment_mode.upcase == "CREDITCARD"
  end

  def payments
    self.payment_order.payments
  end

  def requested_amount_value
    self.payment_order.amount_requested&.value
  end

  private

  def self.status_ids(*statuses)
    status_ids = []
    statuses.each do |status|
      status_ids.push BankPaymentRequestStatus.id_for(status)
    end

    status_ids.reject { |status_id| status_id.nil? }
  end

  def self.document_owner_attribute
    'owner_id'
  end

  def self.document_status_attribute
    'status_id'
  end

  def generate_name
    "PR_#{self.owner.name.downcase.split.join('_')}_#{Time.now.strftime("%d.%m.%y")}"
  end
end
