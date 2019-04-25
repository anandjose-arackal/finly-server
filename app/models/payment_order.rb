# == Schema Information
#
# Table name: payment_orders
#
#  id                        :integer          not null, primary key
#  scheduled_at              :date
#  processed_at              :datetime
#  initiating_user_id        :integer          not null
#  payment_order_status_id   :integer          not null
#  payment_file_file_name    :string(255)
#  payment_file_content_type :string(255)
#  payment_file_file_size    :integer
#  payment_file_updated_at   :datetime
#  company_id                :integer          not null
#  amount_requested_id       :integer
#  amount_processed_id       :integer
#  note                      :text(65535)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  initiating_account_type   :string(255)
#  receiving_account_type    :string(255)
#  payment_purpose_id        :integer          not null
#  currency_id               :integer          not null
#  application               :string(255)
#  payment_mode              :string(255)
#  post_operation            :text(65535)
#  post_operation_payload    :text(65535)
#  api_initiated             :boolean          default(FALSE)
#

class PaymentOrder < ApplicationRecord
  include PostOperationExecution

  CONFIG = {
      meal_card: {
          subscription: :meal_card_enabled,
          card_program_id: CardProgram.id_for(:meal),
          payment_type_id: PaymentType.id_for(:credit),
          payment_purpose_id: PaymentPurpose.id_for(:meal_benefit)
      },
      medical_card: {subscription: :medical_card_enabled,
                     card_program_id: CardProgram.id_for(:medical),
                     payment_type_id: PaymentType.id_for(:credit),
                     payment_purpose_id: PaymentPurpose.id_for(:medical_benefit)
      },
      expense_card: {subscription: :expense_card_enabled,
                     card_program_id: CardProgram.id_for(:expense),
                     payment_type_id: PaymentType.id_for(:credit),
                     payment_purpose_id: PaymentPurpose.id_for(:advance)
      },
      reimbursement_card: {subscription: :reimbursement_card_enabled,
                           card_program_id: CardProgram.id_for(:reimbursement),
                           payment_type_id: PaymentType.id_for(:credit),
                           payment_purpose_id: PaymentPurpose.id_for(:reimbursement)
      }
  }

  belongs_to :payment_purpose, optional: true
  belongs_to :payment_order_status, optional: true
  belongs_to :company, optional: true
  belongs_to :amount_requested, optional: true, class_name: 'Amount'
  belongs_to :amount_processed, optional: true, class_name: 'Amount'
  belongs_to :initiating_user, optional: true, class_name: 'User'
  belongs_to :currency, optional: true

  serialize :post_operation_payload, Hash

  has_one :bank_payment_request
  has_many :payments, dependent: :destroy
  has_many :payment_order_attachments, dependent: :destroy
  has_many :system_messages, as: :messagable, dependent: :destroy

  has_attached_file :payment_file, default_url: '/images/:style/missing.png'
  validates_attachment_content_type :payment_file,
                                    content_type: %w(application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet text/csv)

  validates :payment_purpose_id, presence: true
  validates :initiating_user_id, presence: true
  validates :payment_order_status_id, presence: true
  validates :company_id, presence: true
  validates :currency_id, presence: true

  accepts_nested_attributes_for :amount_requested
  accepts_nested_attributes_for :amount_processed
  accepts_nested_attributes_for :payments
  accepts_nested_attributes_for :payment_order_attachments

  scope :with_purpose_id, -> (id) {where payment_purpose_id: id}
  scope :without_purpose_id, -> (id) {where.not payment_purpose_id: id}
  scope :with_id, -> (id) {where id: id}
  scope :without_id, -> (id) {
    if id.present?
      where.not(id: id)
    end
  }
  scope :with_status, ->(status_id) {where payment_order_status_id: status_id}
  scope :scheduled, -> {with_status(PaymentOrderStatus.id_for(:scheduled))}
  scope :scheduled_on_or_before, -> (date) {where('scheduled_at <= ?', date).where(payment_order_status_id: PaymentOrderStatus.id_for(:scheduled))}
  scope :completed, -> {where payment_order_status_id: PaymentOrderStatus.id_for(:completed)}
  scope :joins_amount_requested, -> {joins :amount_requested}
  scope :total_amount_requested, -> {joins_amount_requested.sum(:value)}
  scope :with_company_id, ->(company_id) {where company_id: company_id}
  scope :with_application, -> (application) {where application: application}
  scope :not_open, -> {where.not(payment_order_status_id: PaymentOrderStatus.id_for(:open))}
  scope :with_initiating_account_type, -> (receiving_account_type) {
    where initiating_account_type: receiving_account_type
  }
  scope :with_initiating_user_id, -> (user_id) {
    where initiating_user_id: user_id
  }

  scope :with_initiating_or_receiving_user, -> (user_id) {
    where('initiating_user_id = ? OR receiving_user_id = ?', user_id, user_id)
  }

  scope :with_receiving_account_type, -> (account_type) {
    where receiving_account_type: account_type
  }

  scope :from_company_account, -> (enabled) {
    if ['1', 1].include?(enabled)
      where initiating_account_type: ["ItzCashCompanyAccount", "YesBankCompanyAccount"]
    end
  }

  scope :vendor_payments, -> (enabled) {
    if enabled == 1 || enabled == '1'
      where payment_purpose_id: PaymentPurpose.id_for(:vendor_payment)
    end
  }

  scope :filter_vendor_payments, -> (enabled) {
    if enabled == 1 || enabled == '1'
      where payment_purpose_id: PaymentPurpose.id_for(:vendor_payment)
    end
  }

  scope :filter_date, -> (date_from, date_to) {
    date_from = "1990-01-01" if date_from.blank?
    date_to = DateUtils.local_date_time if date_to.blank?
    date_from = date_from.to_time if date_from.present?
    date_to = date_to.to_time if date_to.present?
    where('processed_at >= ? AND processed_at <= ?', date_from, date_to)
  }

  scope :with_budgetable_user_ids, -> (user_ids) {
    if user_ids.present?
      where initiating_user_id: user_ids
    end
  }

  scope :from_disburse, -> {where application: ["fd", "ft"]}
  scope :from_vendor_payments, -> {where application: "vp"}

  scope :includes_for_show, -> do
    includes(:initiating_user, :payment_order_status, :initiating_user, {amount_requested: :currency},{amount_processed: :currency}, payments: [{amount: :currency}, :payment_status, :payment_type, :initiating_user, :receiving_user,:system_messages])
  end


  delegate :cancelled?, :completed?, :failed?, :pending?, :in_progress?, :scheduled?, :partially_completed?, to: :payment_order_status
  delegate :amount_requested_value, to: :amount_requested
  delegate :amount_processed_value, to: :amount_processed

  # Avoid showing orders created for ATM withdrawals and Personal Expenses
  default_scope {order(created_at: :desc).without_purpose_id(PaymentPurpose.ids_for([:personal_expense, :atm_withdrawal, :reissue_transfer]))}

  # method for total of all the payments in this particular payment order
  def request_total
    # in case the payment order is not yet created
    if self.id.blank?
      total = 0
      self.payments.each do |payment|
        total += payment.amount.value
      end
      return total
    end
    self.payments.joins(:amount).sum(:value)
  end

  def payment_mode
    if super.blank?
      return self.payments.first&.payment_mode
    end
    super
  end

  def payment_type
    self.payments.first&.payment_type&.name&.humanize
  end

  def credit?
    self.payments.first.payment_type_id == PaymentType.id_for(:credit)
  end

  def debit?
    self.payments.first.payment_type_id == PaymentType.id_for(:debit)
  end

  def payment_order_status_name
    case self.payment_order_status_id
    when PaymentOrderStatus.id_for(:processing)
      return "Transaction successful. Awaiting confirmation"
    else
      self.payment_order_status.name.humanize
    end
  end

  # for convenience, just picks this up from the individual payments
  def initiating_account
    self.payments.first&.initiating_account
  end

  def initiating_account_name
    initiating_account = self.initiating_account
    case initiating_account.class.name
    when "ItzCashCompanyAccount"
      return "Company Credits (Card Transfer Pocket)"
    when "UserWallet"
      return "#{initiating_account.user.first_name}'s Finly Money (Card Transfer Pocket)"
    when "VendorPaymentWallet"
      return "#{initiating_account.user.first_name}'s Finly Money (Bank Transfer Pocket)"
    else
      return ""
    end
  end

  def update_processed_amount
    new_amount = self.payments.completed.joins(:amount).sum(:value)
    self.amount_processed&.update(value: new_amount)
  end

  def update_requested_amount
    new_amount = self.payments.joins(:amount).sum(:value)
    self.amount_requested&.update(value: new_amount)
  end

  # again, for convenience, and only applies to bank transfer poyments
  def bank_transfer_type
    payment_mode
  end

  def update_order_status
    status_ids = self.payments.pluck(:payment_status_id)
    if status_ids.include?(PaymentStatus.id_for(:failed))
      # now further check if there are successes as well
      if status_ids.include?(PaymentStatus.id_for(:completed))
        self.update(payment_order_status_id: PaymentOrderStatus.id_for(:partially_completed))
      else # i.e. if there are only failures in this payment order
        self.update(payment_order_status_id: PaymentOrderStatus.id_for(:failed))
      end
    else
      self.update(payment_order_status_id: PaymentOrderStatus.id_for(:completed))
    end
  end

end
