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
#  otp_attempts                   :integer
#  on_hold                        :boolean
#  disabled                       :boolean
#  transfer_mode_id               :integer
#  last_retried_at                :datetime
#

class Payment < ApplicationRecord
  include PostOperationExecution, SoftDeletable, MathUtil
  include LiquidDroppable
  include Exposures::Model::Exposable

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
  belongs_to :company, optional: true
  belongs_to :cost_center, optional: true
  belongs_to :location, class_name: "BranchLocation", optional: true
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

  belongs_to :reference_payment, class_name: "Payment", optional: true

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

  belongs_to :transfer_mode, optional: true, class_name: 'TransferModeCompanyMapping'

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
  scope :with_external_id, -> (external_id) {
    where external_reference_id: external_id
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
  scope :all_except_failed, -> {where payment_status_id: PaymentStatus.all_except_failed}
  scope :payment_processing_bucket, -> {where payment_status_id: PaymentStatus.ids_for_payment_processing_bucket}
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
            OR (receiving_user_type = 'User' AND receiving_user_id IN (?)) OR id LIKE ?", bank_account_ids, vendor_ids, user_ids, "%#{term.to_i}%")
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
      where payment_purpose_id: [PaymentPurpose.id_for(:vendor_payment), PaymentPurpose.id_for(:advance_against_purchase_order), PaymentPurpose.id_for(:utility_bill_payment)]
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
    virtual_account_transactions = VirtualAccountTransaction.where(reference_payment_id: self.pluck(:id))
    # virtual_account_transaction_ids = self.where(reference_resource_type: "VirtualAccountTransaction").pluck(:reference_resource_id)
    # virtual_account_transactions = VirtualAccountTransaction.where(id: virtual_account_transaction_ids)
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
    # because virtual account transactions are linked to the payment now via the foreign key, not the orher way around
    where(id: virtual_account_transactions.pluck(:reference_payment_id))
    # where(reference_resource_type: "VirtualAccountTransaction", reference_resource_id: virtual_account_transactions.pluck(:id))
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
    includes(:payment_status, :amount, :department, :category, :system_messages, :initiating_account, :initiating_user, :receiving_user,
             :receiving_account,
             invoice: [:original_amount, :advance_amount, :tax_amount, :tds_amount, :freight_amount, :balance_due, :gross_amount, :net_amount, :discount_amount,
                            :category, :cost_center, :tds_slab, :amount, :invoice_status, :invoice_attachments, :invoice_items],
             payment_order: [bank_payment_request: [:status]])
  }

  scope :include_minimal_for_index, -> {
    includes(:payment_status, :amount, :receiving_user, :receiving_account, payment_order: [bank_payment_request: [:status]])
  }

  scope :include_for_streamsets, -> {
    # keep this always during conflict - dont add receiving account sub relation
    includes(:payment_status, :amount, :department, :category, :initiating_account, :reference_resource, :initiating_user, :receiving_user,
             :receiving_account,
                  invoice: [:category, :cost_center, :invoice_status, :invoice_type],
                  payment_order: [bank_payment_request: [:status]])
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
  after_save :recalculate_order_summary
  after_save :add_company_id
  after_save :calculate_paid_amount_in_parent_trails
  after_commit :update_parent_status

  after_destroy :budget_trail_destroy
  after_destroy :calculate_paid_amount_in_parent_trails
  after_destroy :reset_status

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

  # def company_id
  #   if super.blank?
  #     self.payment_order&.company_id
  #   end
  # end

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
    when 'SecurityDeposit'
      SecurityDeposit.find_by(id: self.parent_id).as_json
    when 'BbpsBill'
      BbpsBill.find_by(id: self.parent_id).as_json
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


  def neft?
    self.payment_mode == "NEFT" || self.payment_mode == "neft"
  end

  def imps?
    self.payment_mode == "IMPS" || self.payment_mode == "imps"
  end

  def rtgs?
    self.payment_mode == "RTGS" || self.payment_mode == "rtgs"
  end

  def mode
    self.transfer_mode&.mode&.name&.upcase
  end

  def as_json(options={})
    if options[:payment_request_edit]
      return payment_request_show_json(self.parent_type)
    end
  end

  def bank_payment_request
    return self.payment_order&.bank_payment_request
  end

  def payment_mode
    mode || super
  end

  # adding this association to extract the related
  # reference resources for this particular payment
  def reference_resources
    return [] if reference_resource_type.blank?
    return reference_resource_type.constantize.where(reference_payment_id: self.id).reorder(created_at: :desc)
  end

  # since only one virtual account transaction can correspond to a single payment
  # can change in the future, but unlikely
  def virtual_account_transaction
    return nil unless self.reference_resources.first.is_a?(VirtualAccountTransaction)
    self.reference_resources.first
  end

  def bbps_bank_transaction
    return nil unless self.reference_resources.first.is_a?(BbpsYesBankTransaction)
    self.reference_resources.first
  end

  def utr
    return super unless super.blank?
    return self.reference_resources.first&.try(:utr) || self.reference_resource&.utr
  end

  private

  def recalculate_order_summary
    self.payment_order&.update_requested_amount
  end

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

  def reset_status
    case self.parent_type
    when 'Invoice'
      parent_details = initiating_user.company.inward_invoices.non_beneficiary.find_by(id: self.parent_id)
      options = {}
      if parent_details.payments.all_except_failed.joins(:amount).sum(:value).round(2) < parent_details.balance_due.value.to_f
        options = {invoice_status_id: InwardInvoiceStatus.id_for(:unpaid), payable: true}
      else
        options = {invoice_status_id: InwardInvoiceStatus.id_for(:unpaid)}
      end

      parent_details.update options
    when 'PurchaseOrder'
      parent_details = initiating_user.company.purchase_orders.find_by(id: self.parent_id)
      parent_details.update(advance_amount_status_id: AdvanceAmountStatus.id_for(:to_be_processed))
    when "BbpsBill"
      parent = initiating_user.company.bbps_bills.find_by(id: self.parent_id)
      parent.update(status_id: BbpsBillStatus.id_for(:approved))
    end
  end

  def add_company_id
    if self.company_id.blank?
      self.update_columns(company_id: self.payment_order&.company_id)
    end
  end

  def update_parent_status
    if self.completed?
      case self.parent_type
      when 'Invoice'
        parent_details = initiating_user.company.inward_invoices.non_beneficiary.find_by(id: self.parent_id)
        # parent_details.update(invoice_status_id: InwardInvoiceStatus.id_for(:paid))
        parent_details.update_invoice_status
      when 'PurchaseOrder'
        parent_details = initiating_user.company.purchase_orders.find_by(id: self.parent_id)
        parent_details.update(advance_amount_status_id: AdvanceAmountStatus.id_for(:paid))
      when "BbpsBill"
        parent = initiating_user.company.bbps_bills.find_by(id: self.parent_id)
        parent.update(status_id: BbpsBillStatus.id_for(:paid))
      when "SecurityDeposit"
        self.parent.update(status_id: SecurityDepositStatus.id_for(:paid)) if self.parent.payment_agreement_id.present?
      when "BeneficiaryPayment"
        self.parent.update(status_id: BeneficiaryPaymentStatus.id_for(:paid)) if self.parent.payment_agreement_id.present?
      end
    end

    if self.processing?
      case self.parent_type
      when "BbpsBill"
        parent = initiating_user.company.bbps_bills.find_by(id: self.parent_id)
        parent.update(status_id: BbpsBillStatus.id_for(:payment_initiated))
      else
        # do nothing?
      end
    end

    if PaymentStatus.all_except_failed.exclude? self.payment_status_id
      case self.parent_type
      when 'Invoice'
        parent_details = initiating_user.company.inward_invoices.non_beneficiary.find_by(id: self.parent_id)
        total_payments = parent_details.payments.all_except_failed.joins(:amount).sum(:value).round(2)
        invoice_amount = parent_details.balance_due&.value.to_f

        if total_payments < invoice_amount
          parent_details.update payable: true
        else
          parent_details.update payable: false
        end
      end
    end
  end

  def payment_request_show_json(document_type)
    { document_type: document_type,
      document_details: get_document_details(document_type),
      amount_details: get_amount_details(document_type),
      custom_fields: get_custom_fields(document_type),
      custom_field_config: get_custom_field_config(document_type),
      payment_id: self.id,
      attachment_details: get_attachment_details(document_type)
    }
  end

  def get_document_details(document_type)
    case document_type
    when 'Invoice'
      return get_invoice_details
    # PO Advance
    when 'PurchaseOrder'
      return get_po_advance_details
    when 'BeneficiaryPayment'
      return get_beneficiary_details
    end
  end

  def get_invoice_details
    {
      document_type: 'Invoice',
      owner_name: {name: self.receiving_account&.account_owner&.display_name, label: 'Vendor'},
      account_number: { number: self.receiving_account&.account_number },
      ifsc: { code: self.receiving_account&.ifsc },
      beneficiary_type: { type: get_beneficiary_type },
      field_details: get_field_details('Invoice')
    }
  end

  def get_po_advance_details
    {
      document_type: 'PoAdvance',
      owner_name: {name: self.receiving_account&.account_owner&.display_name, label: 'Vendor'},
      account_number: { number: self.receiving_account&.account_number },
      ifsc: { code: self.receiving_account&.ifsc },
      beneficiary_type: { type: get_beneficiary_type },
      field_details: get_field_details('PurchaseOrder')
    }
  end

  def get_beneficiary_details
    {
      document_type: 'BeneficiaryPayment',
      owner_name: {name: self.receiving_account&.account_owner&.display_name, label: 'Vendor'},
      account_number: { number: self.receiving_account&.account_number },
      ifsc: { code: self.receiving_account&.ifsc },
      beneficiary_type: { type: get_beneficiary_type },
      field_details: get_field_details('BeneficiaryPayment')
    }
  end

  def get_field_details(document_type)
    case document_type
    when 'Invoice'
      invoice_field_details
    when 'PurchaseOrder'
      po_advance_field_details
    when 'BeneficiaryPayment'
      get_beneficiary_field_details
    end
  end

  def get_beneficiary_field_details
    parameters = RequestStore.store[:params]
    parameters[:filter_role_id] = [UserRole.id_for(:bank_payment_request_initiator)]
    departments = Company::Departments::Index.(self.parent.creator, parameters).policy_department_filter_mapping rescue nil
    categories = Categories::Index.(self.parent.creator, parameters).vp_categories rescue nil
    cost_centers = CostCenters::Index.(self.parent.creator, parameters).cost_centers rescue nil
    #Reassign filter role id in case parameters is being directly used
    cc_emails = self.parent.payment_notification_users["cc_emails"] rescue []
    #parameters[:filter_role_id] = [UserRole.id_for(:bank_payment_request_initiator)]
    {
      invoice_number: { value: self.invoice.invoice_number, editable: true, field_type: 'field_text' },
      invoice_date: { value: self.invoice.date, editable: true, field_type: 'field_text' },
      due_date: { value: self.invoice.due_date, field_type: 'field_text', editable: true },
      category: { id: self.invoice.category_id, name: self.invoice&.category&.name, editable: true, field_type: 'field_drop_down_item' },
      cost_center: { id: self.invoice.cost_center_id, name: self.invoice&.cost_center&.name, editable: true, field_type: 'field_drop_down_item' },
      department: { id: self.invoice.department_id, name: self.invoice&.department&.name, editable: true, field_type: 'field_drop_down_item' },
      narration: { value: self.note, editable: true, field_type: 'field_text_area' },
      categories: categories,
      cost_centers: cost_centers,
      departments: departments,
      cc_emails: { value: cc_emails, editable: true, field_type: 'multi_select'}
    }
  end

  def po_advance_field_details
    po = self&.purchase_order
    parameters = RequestStore.store[:params]
    parameters[:filter_role_id] = [UserRole.id_for(:purchase_order_initiator)]
    departments = Company::Departments::Index.(self.purchase_order.user, parameters).policy_department_filter_mapping rescue nil
    locations = Company::Locations::Index.(self.purchase_order.user, parameters).policy_location_filter_mapping
    categories = Categories::Index.(self.purchase_order.user, parameters).vp_categories rescue nil
    cost_centers = CostCenters::Index.(self.purchase_order.user, parameters).cost_centers rescue nil
    #Reassign filter role id in case parameters is being directly used
    parameters[:filter_role_id] = [UserRole.id_for(:bank_payment_request_initiator)]
    {
      po_number: { value: self.purchase_order.po_number, editable: false, field_type: 'field_text' },
      invoice_number: "",
      invoice_date: "",
      due_date: "",
      category: "",
      cost_center: { id: self.purchase_order.cost_center_id, name: self.purchase_order&.cost_center&.name, editable: false, field_type: 'field_drop_down_item' },
      department: { id: self.purchase_order.department_id, name: self.purchase_order&.department&.name, editable: false, field_type: 'field_drop_down_item' },
      location: { id: self.purchase_order.location_id, name: self.purchase_order&.location&.name, editable: false, field_type: 'field_drop_down_item' },
      narration: { value: self.note, editable: false, field_type: 'field_text_area' },
      categories: categories,
      cost_centers: cost_centers,
      departments: departments,
      locations: locations
    }
  end

  def invoice_field_details
    po = self&.invoice&.procurement&.purchase_order
    parameters = RequestStore.store[:params]
    parameters[:filter_role_id] =  po.present? ? [UserRole.id_for(:po_invoice_initiator)] : [UserRole.id_for(:non_po_invoice_initiator)]
    departments = Company::Departments::Index.(self.invoice.created_by, parameters).policy_department_filter_mapping rescue nil
    categories = Categories::Index.(self.invoice.created_by, parameters).vp_categories rescue nil
    cost_centers = CostCenters::Index.(self.invoice.created_by, parameters).cost_centers rescue nil
    #Reassign filter role id in case parameters is being directly used
    parameters[:filter_role_id] = [UserRole.id_for(:bank_payment_request_initiator)]
    {
      invoice_number: { value: self.invoice.invoice_number, editable: false, field_type: 'field_text' },
      invoice_date: { value: self.invoice.date, editable: false, field_type: 'field_text' },
      due_date: { value: self.invoice.due_date, field_type: 'field_text', editable: false },
      category: { id: self.invoice.category_id, name: self.invoice&.category&.name, editable: false, field_type: 'field_drop_down_item' },
      cost_center: { id: self.invoice.cost_center_id, name: self.invoice&.cost_center&.name, editable: false, field_type: 'field_drop_down_item' },
      department: { id: self.invoice.department_id, name: self.invoice&.department&.name, editable: false, field_type: 'field_drop_down_item' },
      narration: { value: self.note, editable: false, field_type: 'field_text_area' },
      categories: categories,
      cost_centers: cost_centers,
      departments: departments,
      rcm_enabled: self.invoice&.rcm_enabled
    }
  end

  def get_beneficiary_type
    if self.receiving_user&.is_a?(User) || self.receiving_user&.authorized
      beneficiary_type = "authorized"
    else
      beneficiary_type = "unauthorized"
    end
    beneficiary_type
  end

  def get_amount_details(document_type)
    case document_type
    when 'Invoice'
      get_invoice_amount_details
    when 'PurchaseOrder'
      get_po_advance_amount_details
    when 'BeneficiaryPayment'
      get_beneficiary_amount_details
    end
  end

  def get_po_advance_amount_details
    parameters = RequestStore.store[:params]
    tds_slabs = TdsSlabs::Index.(self.purchase_order.user, parameters).tds_slabs rescue nil
    {
        total_amount: {value: precision_value(self.purchase_order&.requested_advance_amount&.value), editable: false}, # TOTAL
        inclusive_of_taxes: "",
        discount: "",
        tax: "",
        tds: { tds_slab_id: self.purchase_order.advance_tds_slab_id, tds_amount: self.purchase_order&.advance_tds_amount&.value, editable: true, tds_slab_rate: self.purchase_order&.advance_tds_slab&.tds },
        advance_amount: "", # Advance
        freight_amount: "",
        net_payable_amount: "",
        net_total: { value: self.amount&.value, editable: false }, #Net Total
        roundoff_amount: { value: 0, editable: false },
        tds_slabs: tds_slabs,
        tax_rates: self.purchase_order.company.tax_rates,
        #gst_type_id: {value: self.purchase_order.gst_type_id, editable: false},
        payment_amount: { value: self.amount_value, editable: true }, #Payable Amount
        balance_due:{ value: self.amount&.value, editable: false } # Invoice AMOUNT
    }
  end

  def get_beneficiary_amount_details
    parameters = RequestStore.store[:params]
    tds_slabs = TdsSlabs::Index.(self.parent.creator, parameters).tds_slabs rescue nil
    {
        total_amount: {value: precision_value(self.parent&.original_amount&.value), editable: true}, # TOTAL
        inclusive_of_taxes: { value: !!self.invoice.inclusive_of_taxes, editable: true},
        #discount: "",
        #tax_type_id: { value: self.invoice.tax_type_id, editable: true },
        tax: { tax_type_id: self.invoice.gst_type_id, tax_amount: precision_value(self.parent.tax_amount&.value), value: precision_value(self.invoice.tax_rate), editable: true },
        tax_rate: {tax_rate_id: self.parent.tax_rate_id, editable: true},
        tds: { tds_slab_id: self.invoice.tds_type_id, tds_amount: precision_value(self.parent.tds_amount&.value), tds_slab_id: self.parent.tds_slab_id, editable: true, tds_slab_rate: self.parent&.tds_slab&.tds },
        advance_amount: { value: precision_value(self.parent.advance_amount&.value), editable: true }, # Advance
        freight_amount: "",
        net_payable_amount: "",
        net_total: { value: precision_value(self.parent.net_amount&.value), editable: true }, #Net Total
        roundoff_amount: { value: self.parent.roundoff_amount, editable: true },
        tds_slabs: tds_slabs,
        tax_rates: self.invoice.company.tax_rates,
        gst_type_id: {value: self.invoice.gst_type_id, editable: true},
        payment_amount: { value: self.amount_value, editable: false }, #Payable Amount
        balance_due:{ value: self.parent.balance_due&.value, editable: true } # Invoice AMOUNT
    }
  end

  def get_invoice_amount_details
    parameters = RequestStore.store[:params]
    tds_slabs = TdsSlabs::Index.(self.invoice.created_by, parameters).tds_slabs rescue nil
    if self.parent.invoice_type_id == InwardInvoiceType.id_for(:tax_invoice)
      invoice_advance = self.parent.po_adjusted_advance&.value&.to_f
    elsif self.parent.invoice_type_id == InwardInvoiceType.id_for(:non_po_invoice)
      invoice_advance = self.parent.advance_amount&.value&.to_f
    else
      invoice_advance = self.parent.advance_amount&.value&.to_f
    end

    {
      tds_applicable_amount: calculate_tds_applicable_amount('Invoice'),
      total_amount: {value: precision_value(self.parent&.item_amounts_total), editable: false}, # TOTAL
      inclusive_of_taxes: {value: self.parent.inclusive_of_taxes, editable: false},
      discount: { discount_type_id: self.parent.discount_type_id, rate: self.parent.discount, discount_amount: precision_value(self.parent.discount_amount&.value), editable: false},
      tax: { tax_type_id: self.parent.tax_type_id, tax_amount: precision_value(self.parent.tax_amount&.value), value: precision_value(self.parent.tax), editable: false },
      tds: { tds_slab_id: self.parent.tds_slab_id, tds_amount: precision_value(self.parent.tds_amount&.value), editable: true, tds_slab_rate: self.parent&.tds_slab&.tds},
      advance_amount: { value: invoice_advance, editable: false }, # Advance
      freight_amount: { value: self.parent.freight_amount&.value, editable: false },
      net_payable_amount: { value: self.parent.balance_due&.value, editable: false },
      net_total: { value: self.parent.net_amount&.value, editable: false }, #Net Total
      roundoff_amount: { value: self.parent.roundoff_amount, editable: false },
      tds_slabs: tds_slabs,
      tax_rates: self.parent.company.tax_rates,
      gst_type_id: { value: self.parent.gst_type_id, editable: false },
      payment_amount: { value: self.amount_value, editable: true }, #Payable Amount
      balance_due:{ value: self.parent.balance_due&.value, editable: false }, # Invoice AMOUNT
      available_credits: available_credits_amount
    }
  end

  def get_custom_fields(document_type)
    case document_type
    when 'Invoice'
      self.parent.custom_fields
    when 'PurchaseOrder'
      self.purchase_order.custom_fields
    when 'BeneficiaryPayment'
      self.invoice.custom_fields
    end
  end

  def get_attachment_details(document_type)
    case document_type
    when 'Invoice'
      {
        url: self.parent.attachments.first&.file&.url,
        thumb: self.parent.attachments.first&.file&.url(:thumb),
        content_type: self.parent.attachments.first&.file&.content_type,
        file_name: self.parent.attachments.first&.file&.original_filename
      }
    when 'PurchaseOrder'
      {
        url: self.parent.attachments.first&.file&.url,
        thumb: self.parent.attachments.first&.file&.url(:thumb),
        content_type: self.parent.attachments.first&.file&.content_type,
        file_name: self.parent.attachments.first&.file&.original_filename
      }
    when 'BeneficiaryPayment'
      {
        url: nil,
        thumb: nil,
        content_type: nil,
        file_name: nil
      }
    end
  end

  def calculate_tds_applicable_amount(document_type)
    case document_type
    when 'Invoice'
      return calculate_tds_applicable_sum(self.invoice)
    end
  end

  # Amount on which TDS is applied
  def calculate_tds_applicable_sum(document)
    amount_arr = []
    case document.class.name
    when 'Invoice'
      # Get value from line items
      if ["non_po_invoice", "recurring_invoice", "agreement_invoice"].include?(document.invoice_type.name)
        document.items.joins(:inventory_line_item).where('items.tds_applicable = ?', true).each do |item|
          amount_arr << item.taxable_amount&.value
        end
      elsif document.invoice_type.name == 'tax_invoice'
        document.items.joins(:inventory_line_item).where('items.tds_applicable = ?', true).each do |item|
          if item.inventory_line_item.product_type.goods?
            amount_arr << item.taxable_amount&.value
          else
            amount_arr << item.billable_amount&.value
          end
        end
      end
    end
    return precision_value(amount_arr.sum)
  end

  def get_custom_field_config(document_type)
    case document_type
    when 'BeneficiaryPayment'
      invoice_cf_ids = self.invoice.custom_fields.pluck(:field_configuration_id)
      # Non created custom fields in the config
      configurations = initiating_user.company.field_configurations.where.not(id: invoice_cf_ids).exclude_deleted.root_fields.order_created_at_desc
      custom_fields_config = configurations.with_parent_type(FieldParentType.id_for(:invoice))
    end
  end

  def available_credits_amount
    adj_amount =  self.parent.credit_note_adjustments.joins(:amount).pluck('amounts.value').sum rescue nil
    precision_value(adj_amount)
  end


  # aim of this method is to keep track of how much was paid against an invoice or PO annd enusuring that amount isn't considered in the
  # buckets before payment is released for budgets
  def calculate_paid_amount_in_parent_trails
    if self.parent.present?
      case parent_type
      when "Invoice"
        invoice = self.parent
        parent_trails = BudgetTrail.where(entity_type: "InvoiceLineItem", entity_id: invoice.items.pluck(:id))
        # if there are no such trails, then we can return safely from this block and not execute any of the below statements
        return true if parent_trails.blank?

        paid_amount = invoice.payments.successful.joins(:amount).sum(:value) + invoice.advance_amount&.value.to_f
        payment_processing_amount = invoice.payments.payment_processing_bucket.joins(:amount).sum(:value)
        paid_percent_before_tax = paid_amount / invoice.amount_before_tax
        paid_percent_after_tax = paid_amount / invoice.amount_after_tax
        processing_percent_before_tax = payment_processing_amount / invoice.amount_before_tax
        processing_percent_after_tax = payment_processing_amount / invoice.amount_after_tax

        sql_before_tax = "UPDATE `budget_trails` SET `paid_amount_before_tax_value` = (#{paid_percent_before_tax} * (billed_amount_before_tax_value))
                                                WHERE `budget_trails`.`id` IN (#{parent_trails.pluck(:id).join(",").to_s})"
        ActiveRecord::Base.connection.execute(sql_before_tax)
        sql_before_tax = "UPDATE budget_trails SET `payment_processing_amount_before_tax_value` = (#{processing_percent_before_tax} * (billed_amount_before_tax_value))
                                              WHERE `budget_trails`.`id` IN (#{parent_trails.pluck(:id).join(",").to_s})"
        ActiveRecord::Base.connection.execute(sql_before_tax)
        sql_after_tax = "UPDATE `budget_trails` SET `paid_amount_after_tax_value` = (#{paid_percent_after_tax} * (billed_amount_after_tax_value))
                                                WHERE `budget_trails`.`id` IN (#{parent_trails.pluck(:id).join(",").to_s})"
        ActiveRecord::Base.connection.execute(sql_after_tax)
        sql_after_tax = "UPDATE budget_trails SET `payment_processing_amount_after_tax_value` = (#{processing_percent_after_tax} * (billed_amount_after_tax_value))
                                             WHERE `budget_trails`.`id` IN (#{parent_trails.pluck(:id).join(",").to_s})"
        ActiveRecord::Base.connection.execute(sql_after_tax)
      when "PurchaseOrder"
        purchase_order = self.parent
        parent_trails = BudgetTrail.where(entity_type: "PurchaseOrderItem", entity_id: purchase_order.items.pluck(:id))
        # if there are no such trails, then we can return safely from this block and not execute any of the below statements
        return true if parent_trails.blank?

        paid_amount = purchase_order.payments.successful.joins(:amount).sum(:value)
        payment_processing_amount = purchase_order.payments.payment_processing_bucket.joins(:amount).sum(:value)
        paid_percent_before_tax = paid_amount / purchase_order.amount_before_tax
        paid_percent_after_tax = paid_amount / purchase_order.amount_after_tax
        processing_percent_before_tax = payment_processing_amount / purchase_order.amount_before_tax
        processing_percent_after_tax = payment_processing_amount / purchase_order.amount_after_tax

        sql_before_tax = "UPDATE `budget_trails` SET `paid_amount_before_tax_value` = (#{paid_percent_before_tax} * remaining_amount_before_tax_value)
                                                WHERE `budget_trails`.`id` IN (#{parent_trails.pluck(:id).join(",").to_s})"
        ActiveRecord::Base.connection.execute(sql_before_tax)
        sql_before_tax = "UPDATE budget_trails SET `payment_processing_amount_before_tax_value` = (#{processing_percent_before_tax} * remaining_amount_before_tax_value)
                                              WHERE `budget_trails`.`id` IN (#{parent_trails.pluck(:id).join(",").to_s})"
        ActiveRecord::Base.connection.execute(sql_before_tax)
        sql_after_tax = "UPDATE `budget_trails` SET `paid_amount_after_tax_value` = (#{paid_percent_after_tax} * remaining_amount_after_tax_value)
                                                WHERE `budget_trails`.`id` IN (#{parent_trails.pluck(:id).join(",").to_s})"
        ActiveRecord::Base.connection.execute(sql_after_tax)
        sql_after_tax = "UPDATE budget_trails SET `payment_processing_amount_after_tax_value` = (#{processing_percent_after_tax} * remaining_amount_after_tax_value)
                                             WHERE `budget_trails`.`id` IN (#{parent_trails.pluck(:id).join(",").to_s})"
        ActiveRecord::Base.connection.execute(sql_after_tax)
      else
        # yet to handle security deposit and rental invoice TODO
        return true
      end
    end

      # the below is to do the same, but with report reimbursements and their respective expenses
      # We will be extracting the report_processor_group_mapping for this payment, and then updating the
      # paid amount for all the expenses inside all those reports that have been paid against
      # below not needed because we are directly calculating the amount from the trails
      # if PaymentPurpose.ids_for(:reimbursement, :reimbursement_outside_finly).include?(self.payment_order.payment_purpose_id)
      #   report_processor_mapping = ReportProcessorGroupMapping.find_by(payment_id: self.id)
      #   report_ids = report_processor_mapping.reports.pluck(:id)
      #   expense_trails = BudgetTrail.where(entity_type: "Expense", entity_id: Expense.with_report_id(report_ids).pluck(:id))
      #   if self.completed?
      #     sql_before_tax = "UPDATE `budget_trails` SET `paid_amount_before_tax_value` = `billed_amount_before_tax_value` WHERE `budget_trails`.`id` IN (#{expense_trails.pluck(:id).join(",").to_s})"
      #   # below will only come in if we want to track the settlements that are in processing but not credited yet. So
      #   # that amount will go into the payment processing bucket. As of now, the amount moves diretly from the pending payment bucket to paid bucket
      #   # else
      #   #   sql_before_tax = "UPDATE `budget_trails` SET `payment_processing_amount_before_tax_value` = `billed_amount_before_tax_value` WHERE `budget_trails`.`id` IN (#{expense_trails.pluck(:id).join(",").to_s})"
      #   end
      #   ActiveRecord::Base.connection.execute(sql_before_tax)
      #   if self.completed?
      #     sql_after_tax = "UPDATE `budget_trails` SET `paid_amount_after_tax_value` = `billed_amount_after_tax_value` WHERE `budget_trails`.`id` IN (#{expense_trails.pluck(:id).join(",").to_s})"
      #     # below will only come in if we want to track the settlements that are in processing but not credited yet. So
      #     # that amount will go into the payment processing bucket. As of now, the amount moves diretly from the pending payment bucket to paid bucket
      #   # else
      #   #   sql_after_tax = "UPDATE `budget_trails` SET `payment_processing_amount_after_tax_value` = `billed_amount_after_tax_value` WHERE `budget_trails`.`id` IN (#{expense_trails.pluck(:id).join(",").to_s})"
      #   end
      #   ActiveRecord::Base.connection.execute(sql_after_tax)
      # end
  end

  def budget_trail_entry
    if self.failed?
      # i.e. anytime this payment is updated and it moves to a failed state etc. destroy the respectie trail object
      BudgetManager::BudgetsCalculator::Calculate::PaymentBudgetsProcessor.new.destroy_trail(self)
    else
      BudgetManager::BudgetsCalculator::Calculate::PaymentBudgetsProcessor.new.save_trail(self)
    end
  end

  def budget_trail_destroy
    BudgetManager::BudgetsCalculator::Calculate::PaymentBudgetsProcessor.new.destroy_trail(self)
  end
end
