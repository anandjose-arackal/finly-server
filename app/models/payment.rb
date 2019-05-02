# == Schema Information
#
# Table name: payments
#
#  id                             :integer          not null, primary key
#  amount_id                      :integer          not null
#  date                           :date             not null
#  payment_type_id                :integer          not null
#  initiating_user_id             :integer
#  receiving_user_id              :integer
#  note                           :text(65535)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  initiating_account_id          :integer
#  initiating_account_type        :string(255)
#  receiving_account_id           :integer
#  receiving_account_type         :string(255)
#  payment_order_id               :integer
#  payment_status_id              :integer          not null
#  initiating_user_type           :string(255)
#  receiving_user_type            :string(255)
#  payment_purpose_id             :integer
#  reference_resource_id          :integer
#  reference_resource_type        :string(255)
#  application                    :string(255)
#  payment_mode                   :string(255)
#  reference_id                   :string(255)      not null
#  retry_count                    :integer          default(0)
#  invoice_id                     :integer
#  parent_type                    :string(255)
#  parent_id                      :integer
#  post_operation                 :text(65535)
#  post_operation_payload         :text(65535)
#  category_id                    :integer
#  api_initiated                  :boolean          default(FALSE)
#  original_payment_for_refund_id :integer
#  destination_pocket_id          :integer
#  scheduled_at                   :date
#  processed_at                   :date
#  cost_center_id                 :integer
#  company_id                     :integer
#  external_reference_id          :string(255)
#  purchase_order_id              :integer
#  procurement_id                 :integer
#  department_id                  :integer
#  location_id                    :integer
#  deleted_at                     :datetime
#  beneficiary_payment_id         :integer
#  bank_account_provider_id       :integer
#  otp                            :string(255)
#  opt_attempts                   :integer
#

class Payment < ApplicationRecord
  include PostOperationExecution, SoftDeletable, MathUtil

  class Payment::AccountType
    VIRTUAL_ACCOUNT = 'Company'
    WALLET = 'UserWallet'
    CARD = 'Card'
  end

  belongs_to :amount, optional: true
  belongs_to :payment_type, optional: true
  belongs_to :initiating_user, optional: true, polymorphic: true
  belongs_to :receiving_user, optional: true, polymorphic: true
  belongs_to :reference_resource, optional: true, polymorphic: true
  belongs_to :original_payment_for_refund, optional: true, class_name: "Payment"
  belongs_to :category, optional: true
  belongs_to :department, optional: true
  has_many :reimbursed_reports, class_name: 'Report', foreign_key: :reimbursement_id
  has_many :cash_in_hand_settled_reports, class_name: 'Report', foreign_key: :cash_in_hand_deduction_id
  has_many :report_tracks
  has_many :money_requests
  has_many :money_request_tracks
  has_many :finly_transactions

  # From Procurement Workflow
  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable

  # link to budget trails table
  has_many :budget_trails, as: :entity

  has_one :payment, as: :reference_resource

  # because there needs to be a reference against which an invoice payment was made
  belongs_to :invoice, optional: true

  belongs_to :parent, optional: true, polymorphic: true

  belongs_to :payment_order, optional: true
  belongs_to :payment_status, optional: true
  belongs_to :payment_purpose, optional: true
  belongs_to :purchase_order, optional: true

  belongs_to :destination_pocket, optional: true, class_name: "UserPocket"

  belongs_to :initiating_account, optional: true, polymorphic: true
  belongs_to :receiving_account, optional: true, polymorphic: true

  has_many :system_messages, as: :messagable, dependent: :destroy

  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :payment_order
  accepts_nested_attributes_for :receiving_account
  accepts_nested_attributes_for :invoice

  delegate :amount_value, to: :amount

  default_scope { order date: :desc, created_at: :desc }

  scope :with_id, -> (id) { where id: id }
  scope :without_id, -> (id) {
    if id.present?
      where.not(id: id)
    end
  }
  scope :atm_withdrawals, -> { where payment_purpose_id: PaymentPurpose.id_for(:atm_withdrawal) }
  scope :advance, -> { where payment_purpose_id: [PaymentPurpose.id_for(:advance),
                                                  PaymentPurpose.id_for(:cash_advance),
                                                  PaymentPurpose.id_for(:advance_outside_finly),
                                                  PaymentPurpose.id_for(:advance_against_report_unapproval)] }
  scope :cash_on_hand_additions, -> { where payment_purpose_id: [PaymentPurpose.id_for(:advance_outside_finly), PaymentPurpose.id_for(:cash_advance)] }
  scope :reimbursement, -> { where payment_purpose_id: [PaymentPurpose.id_for(:reimbursement), PaymentPurpose.id_for(:reimbursement_outside_finly)] }
  scope :debt_clearance, -> { where payment_purpose_id: [PaymentPurpose.id_for(:balance_clearance), PaymentPurpose.id_for(:balance_clearance_outside_finly)] }
  scope :cash_on_hand_deductions, -> { where payment_purpose_id: [PaymentPurpose.id_for(:balance_clearance_outside_finly)] }
  scope :settlement, -> { where payment_purpose_id: PaymentType.id_for(:settlement) }
  scope :involving_user, ->(user_id) { where('receiving_user_id = ? OR initiating_user_id = ?', user_id, user_id) }
  scope :involving_account, ->(account) { where('(initiating_account_id = ? AND initiating_account_type = ?) OR (receiving_account_id = ? and receiving_account_type = ?)', account.id, account.class.name, account.id, account.class.name) }
  scope :received_by_user, ->(user_id) { where receiving_user_id: user_id }
  scope :initiated_by_user, ->(user_id) { where initiating_user_id: user_id }
  scope :transferred_cash_to_user, -> { where payment_type: [PaymentPurpose.id_for(:advance_outside_finly), PaymentPurpose.id_for(:cash_advance),
                                                             PaymentPurpose.id_for(:reimbursement), PaymentPurpose.id_for(:reimbursement_outside_finly),
                                                             PaymentPurpose.id_for(:atm_withdrawal)] }
  scope :with_amount, -> { joins :amount }
  scope :with_category, -> (ids) {where category_id: ids}
  scope :with_invoice, -> (ids) { where invoice_id: ids }
  scope :sum_amounts, -> { with_amount.sum(:value) }
  scope :joins_amount, -> { joins :amount }
  scope :made_before, ->(date) { where 'date <= ?', date }
  scope :made_after, ->(date) { where 'date >= ?', date }
  scope :with_details, -> { includes :amount, :initiating_user, :receiving_user, :payment_type }
  scope :scheduled, -> { where payment_status_id: PaymentStatus.id_for(:scheduled) }
  scope :creditable, -> { where payment_status_id: [PaymentStatus.id_for(:failed), PaymentStatus.id_for(:pending_approval)] }
  scope :with_receiving_account_type, -> (receiving_account_type) {
    where receiving_account_type: receiving_account_type
  }
  scope :with_receiving_account_id, -> (ids) {
    where receiving_account_id: ids
  }
  scope :with_initiating_account_type, -> (initiating_account_type) {
    where initiating_account_type: initiating_account_type
  }
  scope :with_initiating_account_id, -> (ids) {
    where initiating_account_id: ids
  }

  scope :with_initiating_account, -> (initiating_account) {
    where initiating_account: initiating_account
  }

  scope :with_receiving_account, -> (receiving_account) {
    where receiving_account: receiving_account
  }

  scope :with_receiving_user_type, -> (type) {
    where receiving_user_type: type
  }

  scope :with_company_id, -> (company_id) {
    where company_id: company_id
  }

  scope :filter_api_initiated, -> (api_initiated) {
    if StringUtils.to_bool(api_initiated)
      where api_initiated: api_initiated
    else
      where('api_initiated IS ? OR api_initiated = ?', nil, false)
    end
  }

  # Personal are card transactions from own wallet to own card

  scope :personal, -> { where('initiating_user_id = receiving_user_id AND (payment_purpose_id IN (?) OR (payment_type_id IN (?) AND initiating_account_type IN (?) AND receiving_account_type IN (?)))',
                              [PaymentPurpose.id_for(:atm_withdrawal), PaymentPurpose.id_for(:card_transaction)], [PaymentType.id_for(:credit), PaymentType.id_for(:debit)], [Payment::AccountType::WALLET, Payment::AccountType::CARD],
                              [Payment::AccountType::WALLET, Payment::AccountType::CARD]) }
  scope :non_personal, -> { where.not('initiating_user_id = receiving_user_id AND (payment_purpose_id IN (?) OR (payment_type_id IN (?) AND initiating_account_type IN (?) AND receiving_account_type IN (?)))',
                                      [PaymentPurpose.id_for(:atm_withdrawal), PaymentPurpose.id_for(:card_transaction)], [PaymentType.id_for(:credit), PaymentType.id_for(:debit)], [Payment::AccountType::WALLET, Payment::AccountType::CARD],
                                      [Payment::AccountType::WALLET, Payment::AccountType::CARD]) }
  scope :non_settlement, -> { where.not('initiating_user_id = receiving_user_id AND initiating_account_type IN (?) AND receiving_account_type IN (?)',
                                        [Payment::AccountType::WALLET, Payment::AccountType::CARD], [Payment::AccountType::WALLET, Payment::AccountType::CARD]).where.not(payment_purpose_id: [PaymentPurpose.id_for(:atm_withdrawal)]) }


  scope :with_date, -> (date) { where(date: date) }
  scope :with_date_range, -> (start_date, end_date) { where('date >= ? AND date <= ?', start_date, end_date) }
  scope :with_payment_type_id, -> (payment_type_id) { where payment_type_id: payment_type_id }

  scope :credit_to_card, -> { where(payment_type_id: [PaymentType.id_for(:credit)], receiving_account_type: Payment::AccountType::CARD) }
  scope :credit_to_wallet, -> { where(payment_type_id: [PaymentType.id_for(:credit)], receiving_account_type: Payment::AccountType::WALLET) }
  scope :debit_from_card, -> { where(payment_type_id: [PaymentType.id_for(:debit)], receiving_account_type: Payment::AccountType::CARD) }
  scope :debit_from_wallet, -> { where(payment_type_id: [PaymentType.id_for(:debit)], receiving_account_type: Payment::AccountType::WALLET) }
  scope :credit_from_virtual_account, -> { where(payment_type_id: [PaymentType.id_for(:credit)], initiating_account_type: Payment::AccountType::VIRTUAL_ACCOUNT) }
  scope :debit_to_virtual_account, -> { where(payment_type_id: [PaymentType.id_for(:debit)], initiating_account_type: Payment::AccountType::VIRTUAL_ACCOUNT) }
  scope :debit_to_card, -> { where(payment_type_id: [PaymentType.id_for(:debit)], initiating_account_type: Payment::AccountType::CARD) }
  scope :debit_to_wallet, -> { where(payment_type_id: [PaymentType.id_for(:debit)], initiating_account_type: Payment::AccountType::VIRTUAL_ACCOUNT) }
  scope :credit_from_card, -> { where(payment_type_id: [PaymentType.id_for(:credit)], initiating_account_type: Payment::AccountType::CARD) }
  scope :credit_from_wallet, -> { where(payment_type_id: [PaymentType.id_for(:credit)], initiating_account_type: Payment::AccountType::WALLET) }

  scope :credit_from_virtual_account_to_wallet, -> { where payment_type_id: PaymentType.id_for(:credit), initiating_account_type: Payment::AccountType::VIRTUAL_ACCOUNT, receiving_account_type: Payment::AccountType::WALLET }
  scope :credit_from_virtual_account_to_card, -> { where payment_type_id: PaymentType.id_for(:credit), initiating_account_type: Payment::AccountType::VIRTUAL_ACCOUNT, receiving_account_type: Payment::AccountType::CARD }
  scope :credit_from_card_to_wallet, -> { where payment_type_id: PaymentType.id_for(:credit), initiating_account_type: Payment::AccountType::CARD, receiving_account_type: Payment::AccountType::WALLET }
  scope :credit_from_wallet_to_wallet, -> { where payment_type_id: PaymentType.id_for(:credit), initiating_account_type: Payment::AccountType::WALLET, receiving_account_type: Payment::AccountType::WALLET }
  scope :credit_from_wallet_to_card, -> { where payment_type_id: PaymentType.id_for(:credit), initiating_account_type: Payment::AccountType::WALLET, receiving_account_type: Payment::AccountType::CARD }
  scope :credit_from_card_to_card, -> { where payment_type_id: PaymentType.id_for(:credit), initiating_account_type: Payment::AccountType::CARD, receiving_account_type: Payment::AccountType::CARD }
  scope :debit_from_wallet_to_card, -> { where payment_type_id: PaymentType.id_for(:debit), initiating_account_type: Payment::AccountType::CARD, receiving_account_type: Payment::AccountType::WALLET }
  scope :debit_from_wallet_to_wallet, -> { where payment_type_id: PaymentType.id_for(:debit), initiating_account_type: Payment::AccountType::WALLET, receiving_account_type: Payment::AccountType::WALLET }
  scope :debit_from_wallet_to_virtual_account, -> { where payment_type_id: PaymentType.id_for(:debit), initiating_account_type: Payment::AccountType::VIRTUAL_ACCOUNT, receiving_account_type: Payment::AccountType::WALLET }
  scope :debit_from_card_to_virtual_account, -> { where payment_type_id: PaymentType.id_for(:debit), initiating_account_type: Payment::AccountType::VIRTUAL_ACCOUNT, receiving_account_type: Payment::AccountType::CARD }
  scope :debit_from_card_to_wallet, -> { where payment_type_id: PaymentType.id_for(:debit), initiating_account_type: Payment::AccountType::WALLET, receiving_account_type: Payment::AccountType::CARD }
  scope :debit_from_card_to_card, -> { where payment_type_id: PaymentType.id_for(:debit), initiating_account_type: Payment::AccountType::CARD, receiving_account_type: Payment::AccountType::CARD }
  scope :cash_on_hand_credits, -> { where(receiving_account_type: "CashOnHand") }
  scope :cash_advance, -> { where payment_purpose_id: PaymentPurpose.id_for(:cash_advance) }
  scope :successful, -> { where payment_status_id: PaymentStatus.id_for(:completed) }
  scope :processing, -> { where payment_status_id: PaymentStatus.id_for(:processing) }
  scope :successful_and_failed_only, -> { where payment_status_id: [PaymentStatus.id_for(:completed), PaymentStatus.id_for(:failed)] }
  scope :failed, -> { where payment_status_id: PaymentStatus.id_for(:failed) }
  scope :completed, -> { where payment_status_id: PaymentStatus.id_for(:completed) }
  scope :processed, -> { where payment_status_id: [PaymentStatus.id_for(:completed), PaymentStatus.id_for(:processing)] }
  scope :possible_failure, -> { where payment_status_id: PaymentStatus.id_for(:possible_failure) }
  scope :pending, -> { where payment_status_id: PaymentStatus.id_for(:pending) }
  scope :in_progress, -> { where payment_status_id: PaymentStatus.id_for(:in_progress) }
  scope :pending_approval, -> { where payment_status_id: PaymentStatus.id_for(:pending_approval) }

  scope :transfer_to_card, -> { where('(payment_type_id = ? AND receiving_account_type = ?) OR (payment_type_id = ? AND initiating_account_type = ?)',
                                      PaymentType.id_for(:credit), Payment::AccountType::CARD, PaymentType.id_for(:debit), Payment::AccountType::CARD) }
  scope :personal_transfer_to_card, -> { personal.transfer_to_card }
  scope :non_personal_transfer_to_card, -> { non_personal.transfer_to_card }

  scope :with_application, -> (application) {
    where application: application.to_s
  }

  scope :with_payment_order_id, -> (ids) {
    where payment_order_id: ids
  }

  scope :with_payment_purpose, -> (purpose_id) {
    where payment_purpose_id: purpose_id
  }

  scope :with_payment_status, -> (status_ids) {
    where(payment_status_id: status_ids)
  }

  scope :cash_additions_to_employee, -> { where(payment_purpose_id: [PaymentPurpose.id_for(:advance_outside_finly), PaymentPurpose.id_for(:reimbursement), PaymentPurpose.id_for(:reimbursement_outside_finly)]) }
  scope :cash_deductions_from_employee, -> { where(payment_type_id: [PaymentPurpose.id_for(:balance_clearance_outside_finly)]) }

  scope :credits_for_account, ->(account) { where("(initiating_account_id = ? AND initiating_account_type = ? AND payment_type_id = #{PaymentType.id_for(:debit)}) OR (receiving_account_id = ? and receiving_account_type = ? AND payment_type_id = #{PaymentType.id_for(:credit)})", account.id, account.class.name, account.id, account.class.name) }
  scope :debits_for_account, ->(account) { where("(initiating_account_id = ? AND initiating_account_type = ? AND payment_type_id = #{PaymentType.id_for(:credit)}) OR (receiving_account_id = ? and receiving_account_type = ? AND payment_type_id = #{PaymentType.id_for(:debit)})", account.id, account.class.name, account.id, account.class.name) }
  scope :with_reference_id, -> (ref_id) { where reference_id: ref_id }

  scope :filter_search, -> (term) {
    bank_account_ids = BankAccount.where("account_number like ? OR name like ? OR ifsc like ?", "%#{term}%", "%#{term}%", "%#{term}%").pluck(:id)
    vendor_ids = YesBankVendor.where("name like ? OR email like ? OR mobile_number like ?", "%#{term}%", "%#{term}%", "%#{term}%").pluck(:id)
    user_ids = User.where("first_name like ? OR last_name like ? OR email like ?", "%#{term}%", "%#{term}%", "%#{term}%").pluck(:id)

    where("(receiving_account_type = 'BankAccount' AND receiving_account_id IN (?)) OR (receiving_user_type = 'YesBankVendor' AND receiving_user_id IN (?))
            OR (receiving_user_type = 'User' AND receiving_user_id IN (?))", bank_account_ids, vendor_ids, user_ids)
  }

  scope :filter_search_index, -> (beneficiary_type, receiving_user_id) {
    case beneficiary_type
      when 1, '1'
        where(receiving_user_type: "User", receiving_user_id: receiving_user_id)
      when 2, '2'
        where(receiving_user_type: "YesBankVendor", receiving_user_id: receiving_user_id)
      else
        where(receiving_user_type: "YesBankVendor", receiving_user_id: receiving_user_id)
    end
  }

  scope :filter_status_id, -> (status_id) {
    where(payment_status_id: status_id)
  }

  scope :filter_user_id, -> (user_id) {
    if user_id.present?
      where('initiating_user_id = ? OR receiving_user_id = ?', user_id, user_id)
    end
  }

  scope :filter_vendor_payments, -> (enabled){
    if StringUtils.to_bool(enabled)
      where payment_purpose_id: PaymentPurpose.id_for(:vendor_payment)
    end
  }

  scope :filter_payment_id, -> (payment_id) {
    where id: payment_id
  }

  scope :filter_receiving_user_name, -> (name) {
    vendor_ids = YesBankVendor.where("name like ?", "%#{name}%").pluck(:id)
    user_ids = User.where("first_name like ? OR last_name like ?", "%#{name}%", "%#{name}%").pluck(:id)
    where("(receiving_user_type = 'YesBankVendor' AND receiving_user_id IN (?))
            OR (receiving_user_type = 'User' AND receiving_user_id IN (?))", vendor_ids, user_ids)
  }

  scope :filter_initiating_user_name, -> (name) {
    user_ids = User.where("first_name like ? OR last_name like ?", "%#{name}%", "%#{name}%").pluck(:id)
    where("(initiating_user_type = 'User' AND initiating_user_id IN (?))", user_ids)
  }

  scope :filter_beneficiary_account_number, -> (account_number) {
    bank_account_ids = BankAccount.where("account_number like ?", "%#{account_number}%").pluck(:id)
    where("(receiving_account_type = 'BankAccount' AND receiving_account_id IN (?))", bank_account_ids)
  }

  scope :filter_beneficiary_account_ifsc, -> (ifsc) {
    bank_account_ids = BankAccount.where("ifsc like ?", "%#{ifsc}%").pluck(:id)
    where("(receiving_account_type = 'BankAccount' AND receiving_account_id IN (?))", bank_account_ids)
  }

  scope :filter_date, -> (date_from, date_to) {
    type_val = :date
    date_from = "1990-01-01" if date_from.blank?
    date_to = DateUtils.local_date if date_to.blank?
    date_from = date_from.to_date if date_from.present?
    date_to = date_to.to_date if date_to.present?
    payments = arel_table
    where(payments[type_val].gteq(date_from).and(payments[type_val].lteq(date_to)))
  }

  scope :pending, -> { where payment_status_id: [PaymentStatus.id_for(:pending), PaymentStatus.id_for(:scheduled)] }

  scope :budget_payments, -> (from, to) {
    if from.is_a? Date
      from = from
    else
      from = Date.parse(from.to_s) rescue Date.parse("1993-04-13")
    end
    if to.is_a? Date
      to = to
    else
      to = Date.parse(to.to_s) rescue Date.today
    end
    where("payments.payment_status_id NOT IN (?)", [PaymentStatus.id_for(:failed), PaymentStatus.id_for(:cancelled)]).where("payments.date >= ? AND payments.date <= ?", from, to)
  }

  scope :vendor_payments_only, -> { where receiving_user_type: 'YesBankVendor' }

  scope :unpaid, -> {
    where payment_status_id: [PaymentStatus.id_for(:pending_approval), PaymentStatus.id_for(:failed), PaymentStatus.id_for(:pending_credit)]
  }

  scope :virtual_account_transaction_purpose, -> (purpose_id) {
    virtual_account_transaction_ids = self.where(reference_resource_type: "VirtualAccountTransaction").pluck(:reference_resource_id)
    virtual_account_transactions = VirtualAccountTransaction.where(id: virtual_account_transaction_ids)
    virtual_accounts = VirtualBankAccount.where(id: virtual_account_transactions.pluck(:virtual_account_id))
    case purpose_id
      when 1, '1'
        virtual_account_ids = virtual_accounts.where(purpose_id: VirtualAccountPurpose.id_for(:cash_on_hand_return)).pluck(:id)
      when 2, '2'
        virtual_account_ids = virtual_accounts.where(purpose_id: VirtualAccountPurpose.id_for(:payment_receivable)).pluck(:id)
      when 3, '3'
        virtual_account_ids = virtual_accounts.where(purpose_id: VirtualAccountPurpose.id_for(:invoice)).pluck(:id)
      when 4, '4'
        virtual_account_ids = virtual_accounts.where(purpose_id: VirtualAccountPurpose.id_for(:virtual_bank_account)).pluck(:id)
      when 5, '5'
        virtual_account_ids = virtual_accounts.where(purpose_id: VirtualAccountPurpose.id_for(:corporate_account_reload)).pluck(:id)
      when 6, '6'
        virtual_account_ids = virtual_accounts.where(purpose_id: VirtualAccountPurpose.id_for(:finly_money_reload)).pluck(:id)
      else
        virtual_account_ids = []
    end
    virtual_account_transactions = virtual_account_transactions.where(virtual_account_id: virtual_account_ids)
    where(reference_resource_type: "VirtualAccountTransaction", reference_resource_id: virtual_account_transactions.pluck(:id))
  }

  scope :with_budgetable_category_ids, -> (category_ids) {
    if category_ids.present?
      category_ids = [category_ids] unless category_ids.is_a?(Array)
      where(category_id: category_ids)
    end
  }

  scope :with_budgetable_cost_center_ids, -> (cost_center_ids) {
    if cost_center_ids.present?
      cost_center_ids = [cost_center_ids] unless cost_center_ids.is_a?(Array)
      where(cost_center_id: cost_center_ids)
    end
  }

  scope :with_budgetable_department_ids, -> (department_ids) {
    if department_ids.present?
      where department_id: department_ids
    end
  }

  scope :with_budgetable_location_ids, -> (location_ids) {
    if location_ids.present?
      where(location_id: location_ids)
    end
  }

  scope :with_budgetable_vendor_ids, -> (vendor_ids) {
    if vendor_ids.present?
      where(receiving_user_type: "YesBankVendor", receiving_user_id: vendor_ids)
    end
  }

  scope :include_for_index, -> {
        includes( :payment_status, :amount, :department, :category, :system_messages,:initiating_account,:reference_resource,:initiating_user, :receiving_user,
                  receiving_account: [:account_owner],
                  invoice: [:original_amount, :advance_amount, :tax_amount, :tds_amount, :freight_amount, :balance_due, :gross_amount, :net_amount, :discount_amount,
                            :category, :cost_center, :tds_slab, :amount, :invoice_status, :invoice_attachments, :invoice_items],
                  payment_order: [bank_payment_request: [:status]])
  }

  scope :include_minimal_for_index, -> {
        includes( :payment_status, :amount, :receiving_user, receiving_account: [:account_owner])
  }

  # validates :amount_id, presence: true
  validates :date, presence: true
  validates :external_reference_id, uniqueness: {allow_nil: true, scope: :company_id}
  # validates :initiating_user_id, presence: true
  # validates :receiving_user_id, presence: true
  validate :initiating_user_presence
  validate :receiving_user_presence
  validate :initiating_account_presence
  validate :receiving_account_presence

  delegate :completed?, :failed?, :pending?, :in_progress?, :processing?, :scheduled?, :possible_failure?, :pending_approval?, :pending_retry?, to: :payment_status
  delegate :collect_funds_withdrawal?, to: :payment_purpose

  before_create do
    self.reference_id = Generator.reference_id_for(initiating_account, receiving_account, date)
  end

  after_save :budget_trail_entry

  after_destroy :budget_trail_destroy

  def initiating_account_type_name
    name = "#{initiating_user&.name&.to_s}'s "

    case self.initiating_account_type
      when "Company", "ItzCashCompanyAccount"
        name = "Company Credits (Card Transfer Pocket)"
      when "CashOnHand"
        name += "Cash on Hand"
      when "Card"
        card_type = Card.unscoped.find_by(id: self.initiating_account_id)&.card_program&.name&.humanize
        name += "#{card_type} Card"
      when "UserWallet"
        name += "Finly Money"
      when "YesBankCompanyAccount"
        name = "Company Credits (Bank Transfer Pocket)"
      when "VendorPaymentWallet"
        name += "Finly Money (Bank Transfer Pocket)"
      when "BankAccount"
        name += "Bank Account (Number: #{self.initiating_account.account_number})"
      when "UserPocket"
        name += "#{self.receiving_account.name}"
      else
        name = ""
    end
    name
  end

  alias_method :initiating_account_name, :initiating_account_type_name

  def receiving_account_type_name
    name = "#{receiving_user&.name.to_s}'s "

    case self.receiving_account_type
      when "Company", "ItzCashCompanyAccount"
        name = "Company Credits (Card Transfer Pocket)"
      when "CashOnHand"
        name += "Cash on Hand"
      when "Card"
        card_type = Card.unscoped.find_by(id: self.receiving_account_id)&.card_program&.name&.humanize
        name += "#{card_type} Card"
      when "UserWallet"
        name += "Finly Money"
      when "YesBankCompanyAccount"
        name = "Company Credits (Bank Transfer Pocket)"
      when "VendorPaymentWallet"
        name += "Finly Money (Bank Transfer Pocket)"
      when "BankAccount"
        name += "Bank Account (Number: #{self.receiving_account.account_number})"
      when "UserPocket"
        name += "#{self.receiving_account.name}"
      else
        name = ""
    end
    name
  end

  alias_method :receiving_account_name, :receiving_account_type_name

  def credit?
    self.payment_type_id == PaymentType.id_for(:credit)
  end

  def debit?
    self.payment_type_id == PaymentType.id_for(:debit)
  end

  def advance?
    [PaymentPurpose.id_for(:advance_outside_finly), PaymentPurpose.id_for(:advance)].include?(self.payment_purpose_id)
  end

  def reimbursement?
    [PaymentPurpose.id_for(:reimbursement), PaymentPurpose.id_for(:reimbursement_outside_finly)].include?(self.payment_purpose_id)
  end

  def debt_clearance?
    self.payment_type_id == PaymentType.id_for(:balance_clearance_outside_finly)
  end

  def balance_clearance?
    self.payment_type_id == PaymentType.id_for(:balance_clearance_outside_finly)
  end

  def settlement?
    self.payment_type_id == PaymentType.id_for(:settlement)
  end

  def total_amount
    self.amount.value rescue nil
  end

  def clear_system_messages
    if system_messages.present?
      system_messages.destroy_all
    end
  end

  # only used in the show action of the payment request
  def payment_status_name
    if self.payment_status_id == PaymentStatus.id_for(:processing)
      return "Processed. Awaiting credit confirmation"
    elsif self.payment_order&.bank_payment_request&.status&.name == 'approved'
      return "Approved"
    elsif ['open', 'retracted', 'rejected'].include?(self.payment_order&.bank_payment_request&.status&.name)
      return self.payment_order&.bank_payment_request&.status&.name&.humanize
    else
      self.payment_status.name.humanize
    end
  end

  def cash_on_hand_credit?
    self.payment_purpose_id == PaymentPurpose.id_for(:cash_advance)
  end

  def cash_pocket_credit?
    self.payment_purpose_id == PaymentPurpose.id_for(:cash_advance)
  end

  def retriable?
    self.failed?
  end

  def invoice_amount
    return self.amount.value unless self.invoice.present?
    self.invoice.amount&.value # in this case return the actual invoice amount
  end

  def company_id
    self.payment_order&.company_id
  end

  def procurement_index_details
    {
        id: id,
        document_number: self.id,
        amount: self.amount.value,
        document_owner: self.initiating_user&.name,
        document_status: self.payment_status&.name,
        document_type: self.class.name
    }
  end

  def parent_details
    case self.parent_type
    when 'BeneficiaryPayment'
      BeneficiaryPayment.find_by(id: self.parent_id).as_json
    when 'Invoice'
      Invoice.find_by(id: self.parent_id).as_json
    when 'PurchaseOrder'
      # PurchaseOrder.find_by(id: self.parent_id).as_json(tree: true) # because somewhere we got as_json for PO already. running on deadline. dont have time to remodify.
      PurchaseOrder.find_by(id: self.parent_id).as_json2 # because somewhere we got as_json for PO already. running on deadline. dont have time to remodify.
    else
      if self.invoice.present?
        self.invoice.as_json
      else
        fallback_info
      end
    end
  end





  def get_payable_amount
    case self.parent_type
    when 'BeneficiaryPayment'
      precision_value self.parent.balance_due&.value
    when 'Invoice'
      precision_value self.parent.balance_due&.value
    when 'PurchaseOrder'
      # PurchaseOrder.find_by(id: self.parent_id).as_json(tree: true) # because somewhere we got as_json for PO already. running on deadline. dont have time to remodify.
      precision_value self.parent.advance_amount&.value
    else
      if self.invoice.present?
        precision_value self.invoice.balance_due&.value
      else
        self.amount_value
      end
    end
  end

  def fallback_info
    {
      raw_amount: precision_value(self.amount_value),
      original_amount: precision_value(self.amount_value),
      invoice: {
        net_amount: precision_value(self.amount&.value),
        roundoff_amount: 0,
        balance_due: self.amount&.value
      }
    }
  end




  private

  def initiating_account_presence
    unless PaymentPurpose.ids_for([:advance_outside_finly, :reimbursement_outside_finly, :balance_clearance_outside_finly, :failed_transaction_reversal,
                                   :personal_expense, :atm_withdrawal, :card_transaction, :advance, :corporate_balance_load,
                                   :corporate_balance_refund, :cash_advance, :balance_clearance_against_cash_on_hand, :settlement_against_cash_on_hand,
                                   :advance_against_report_unapproval, :cash_on_hand_reversal, :settlement_against_advance]).include?(self.payment_purpose_id)
      if initiating_account_id.blank? || receiving_account_type.blank?
        errors.add(:initiating_account, "cannot be blank")
      end
    end
  end

  def receiving_account_presence
    unless PaymentPurpose.ids_for([:advance_outside_finly, :reimbursement_outside_finly,
                                   :balance_clearance_outside_finly,
                                   :card_transaction, :atm_withdrawal]).include?(self.payment_purpose_id)
      if receiving_account_id.blank? || receiving_account_type.blank?
        errors.add(:receiving_account, "cannot be blank")
      end
    end
  end

  def initiating_user_presence
    unless PaymentPurpose.ids_for([:vendor_payment, :virtual_account_credit, :payment_link_credit, :invoice_credit,
                                   :cash_on_hand_reversal,:virtual_account_credit,:payment_link_credit, :invoice_credit,
                                   :cash_on_hand_return, :payment_receivable, :invoice, :failed_transaction_reversal,
                                   :virtual_bank_account, :finly_money_reload, :corporate_account_reload]).include?(self.payment_purpose_id)
      if initiating_user_id.blank?
        errors.add(:initiating_user_id, "cannot be blank")
      end
    end
  end

  def receiving_user_presence
    unless PaymentPurpose.ids_for([:vendor_payment, :corporate_balance_load, :corporate_balance_refund, :virtual_account_credit,
                                   :payment_link_credit, :invoice_credit, :cash_on_hand_reversal,:virtual_account_credit,
                                   :payment_link_credit, :invoice_credit, :cash_on_hand_return,  :payment_receivable, :failed_transaction_reversal,
                                   :invoice, :virtual_bank_account, :finly_money_reload, :corporate_account_reload]).include?(self.payment_purpose_id)
      if receiving_user_id.blank?
        errors.add(:receiving_user_id, "cannot be blank")
      end
    end
  end

  def budget_trail_entry
    if self.completed? || self.processing? || self.possible_failure?
      BudgetsCalculator::Calculate::PaymentBudgetsProcessor.new.save_trail(self)
    else
      # i.e. anytime this payment is updated and it moves to a failed state etc. destroy the respectie trail object
      BudgetsCalculator::Calculate::PaymentBudgetsProcessor.new.destroy_trail(self)
    end
  end

  def budget_trail_destroy
    BudgetsCalculator::Calculate::PaymentBudgetsProcessor.new.destroy_trail(self)
    reset_status
  end

  def reset_status
    case self.parent_type
    when 'Invoice'
      parent_details = initiating_user.company.inward_invoices.non_beneficiary.find_by(id: self.parent_id)
      parent_details.update(invoice_status_id: InwardInvoiceStatus.id_for(:unpaid))
    when 'PurchaseOrder'
      parent_details = initiating_user.company.purchase_orders.find_by(id: self.parent_id)
      parent_details.update(advance_amount_status_id: AdvanceAmountStatus.id_for(:to_be_processed))
    end
  end
end
