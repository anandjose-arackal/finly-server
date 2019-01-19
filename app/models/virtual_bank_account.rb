# == Schema Information
#
# Table name: virtual_bank_accounts
#
#  id                            :integer          not null, primary key
#  account_number                :string(255)
#  ifsc                          :string(255)
#  description                   :text(65535)
#  parent_id                     :integer
#  parent_type                   :string(255)
#  company_id                    :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  expires_by                    :date
#  purpose_id                    :integer
#  active                        :boolean          default(TRUE)
#  is_deleted                    :boolean          default(FALSE)
#  initiating_user_id            :integer
#  name                          :string(255)
#  receiving_account_id          :integer
#  receiving_account_type        :string(255)
#  maximum_transaction_amount_id :integer
#  minimum_transaction_amount_id :integer
#  allowed_transaction_count     :integer
#  neft                          :boolean          default(TRUE)
#  imps                          :boolean          default(TRUE)
#  rtgs                          :boolean          default(TRUE)
#  current_account               :boolean          default(TRUE)
#  savings_account               :boolean          default(TRUE)
#  upi                           :boolean          default(TRUE)
#  active_after                  :date
#  active_on                     :date
#  maximum_amount_id             :integer
#  exact_transaction_amount_id   :integer
#  application                   :string(255)      not null
#  customer_id                   :integer
#  default_account               :boolean
#  deleted_at                    :datetime
#

# parent here will be either the payment receivable, or user, or whatever
class VirtualBankAccount < ActiveRecord::Base
  include SoftDeletable

  belongs_to :parent, polymorphic: true
  belongs_to :purpose, class_name: "VirtualAccountPurpose"
  belongs_to :company
  belongs_to :initiating_user, class_name: "User"
  belongs_to :customer
  belongs_to :receiving_account, polymorphic: true
  belongs_to :maximum_transaction_amount, class_name: "Amount"
  belongs_to :minimum_transaction_amount, class_name: "Amount"
  belongs_to :maximum_amount, class_name: "Amount"
  belongs_to :exact_transaction_amount, class_name: "Amount"

  has_many :outward_invoices, foreign_key: :virtual_account_id

  has_many :initiating_payments, as: :initiating_account, class_name: "Payment"

  accepts_nested_attributes_for :maximum_amount
  accepts_nested_attributes_for :maximum_transaction_amount
  accepts_nested_attributes_for :minimum_transaction_amount
  accepts_nested_attributes_for :exact_transaction_amount

  delegate :maximum_amount_value, to: :maximum_amount, allow_nil: true
  delegate :maximum_transaction_amount_value, to: :maximum_transaction_amount, allow_nil: true
  delegate :minimum_transaction_amount_value, to: :minimum_transaction_amount, allow_nil: true
  delegate :exact_transaction_amount_value, to: :exact_transaction_amount, allow_nil: true

  validates :purpose, presence: true
  validates :receiving_account_id, presence: true
  validates :receiving_account_type, presence: true, :inclusion => {:in => [YesBankCompanyAccount.name, VendorPaymentWallet.name, CashOnHand.name]}

  scope :cash_on_hand_returns, -> { where purpose_id: VirtualAccountPurpose.id_for(:cash_on_hand_return) }
  scope :payment_receivables, -> { where purpose_id: VirtualAccountPurpose.id_for(:payment_receivable) }
  scope :virtual_bank_accounts, -> { where purpose_id: VirtualAccountPurpose.id_for(:virtual_bank_account) }
  scope :invoices, -> { where purpose_id: VirtualAccountPurpose.id_for(:invoice) }

  scope :with_customer_id, -> (customer_id) {
    where(customer_id: customer_id)
  }

  scope :filter_search, -> (term) {
    where('account_number like ? OR name like ? OR ifsc like ? OR description like ?', "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%")
  }

  scope :filter_created_by_id, -> (created_by_id) { where initiating_user_id: created_by_id }

  def deactivate
    self.update(active: false)
  end

  def reactivate
    self.update(active: true)
  end

  def payment_link?
    self.parent_type == "PaymentReceivable"
  end

end
