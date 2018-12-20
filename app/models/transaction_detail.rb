
# == Schema Information
#
# Table name: transaction_detail
#
# "transaction_reference_id", string255
# "payment_purpose",          string 255
# "merchant",                 string 255
# "note",                     string 65535
# "transaction_type_id",      integer 4
# "status_id",                integer 4,     null: false
# "amount_id",                integer 4
# "finly_transaction_id",     integer 4
# "opening_balance_id",       integer 4
# "closing_balance_id",       integer 4
# "company_id",               integer 4
# "transaction_date"          datetime
# "created_at",              null: false
# "updated_at",              null: false
#

class TransactionDetail < ActiveRecord::Base

  belongs_to :company
  belongs_to :finly_transaction
  belongs_to :opening_balance, class_name: 'Amount'
  belongs_to :closing_balance, class_name: 'Amount'
  belongs_to :status
  belongs_to :transaction_type
  belongs_to :finly_account, polymorphic: true

  validates :finly_transaction_id, uniqueness: true

end
