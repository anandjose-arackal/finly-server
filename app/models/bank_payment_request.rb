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
#

class BankPaymentRequest < ActiveRecord::Base

  include SoftDeletable

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

  default_scope { order(created_at: :desc) }

  delegate :open?, :submitted?, :retracted?, :rejected?, :approved?, :credited?, :processing?, to: :status
  delegate :requested_amount_value, to: :requested_amount
  delegate :scheduled?, to: :payment_order

  scope :non_owner, -> (user_id) { where.not owner_id: user_id }
  scope :with_controlling_user, -> (user_id) { where controlling_user_id: user_id }
  scope :with_controlling_user_role, -> (role_id) { where controlling_user_role_id: role_id }
  scope :with_user, -> (user_id) { where owner_id: user_id }
  scope :not_open, -> { where.not status_id: BankPaymentRequestStatus.id_for(:open) }
  scope :with_id, -> (id) { where id: id }
  scope :approved, -> { where status_id: BankPaymentRequestStatus.id_for(:approved) }
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

  scope :filter_date, -> (date_from, date_to) {
    date_from = "1990-01-01" if date_from.blank?
    date_to = DateUtils.local_date_time if date_to.blank?
    date_from = date_from.to_time if date_from.present?
    date_to = date_to.to_time if date_to.present?
    joins(:payment_order).where('payment_orders.processed_at >= ? AND processed_at <= ?', date_from, date_to)
  }

  scope :processing, -> { where status_id: BankPaymentRequestStatus.id_for(:processing) }

  scope :includes_details, -> { includes(:status, :owner, :requested_amount)}

  scope :filter_custom_drop_down_selection, -> (drop_down_item_id) {
    drop_down_selection_ids = FieldDropDownSelection.with_value(drop_down_item_id).pluck(:id)
    raw_po_ids = self.pluck(:payment_order_id)
    raw_payment_ids = Payment.where(payment_order_id: raw_po_ids)
    raw_invoice_ids = Invoice.where(payment_id: raw_payment_ids)
    invoice_ids = CustomField.with_drop_down_selection(drop_down_selection_ids).with_parent(raw_invoice_ids, "Invoice").pluck(:parent_id)
    payment_ids = Invoice.where(id: invoice_ids)
    po_ids = Payment.where(id: payment_ids).pluck(:payment_order_id)
    bpr_ids = BankPaymentRequest.where(payment_order_id: po_ids)
    where(id: bpr_ids)
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

  private

  def generate_name
    "PR_#{self.owner.name.downcase.split.join('_')}_#{Time.now.strftime("%d.%m.%y")}"
  end
end
