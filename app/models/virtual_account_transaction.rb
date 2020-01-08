# == Schema Information
#
# Table name: virtual_account_transactions
#
#  id                         :integer          not null, primary key
#  beneficiary_account_ifsc   :string(255)
#  transfer_type              :string(255)
#  beneficiary_full_name      :string(255)
#  transfer_id                :string(255)
#  transfer_timestamp         :string(255)
#  transfer_currency          :string(255)
#  transfer_amount            :string(255)
#  remitter_account_no        :string(255)
#  remitter_account_ifsc      :string(255)
#  remitter_account_type      :string(255)
#  remitter_full_name         :string(255)
#  remitter_address           :string(255)
#  note                       :string(255)
#  credited_at                :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  virtual_account_id         :integer
#  processed                  :boolean
#  receiving_account_credited :boolean
#  beneficiary_account_no     :string(255)
#

class VirtualAccountTransaction < ApplicationRecord
  include SystemLoggable

  has_one :payment, as: :reference_resource
  belongs_to :virtual_account, optional: true, class_name: "VirtualBankAccount"
  has_many :invoice_transaction_mappings, foreign_key: :va_transaction_id
  has_many :invoices, through: :invoice_transaction_mappings

  has_many :customer_account_transactions, as: :associated_object

  validates :transfer_id, uniqueness: true

  scope :with_transfer_id, -> (transfer_id) { where transfer_id: transfer_id }

end
