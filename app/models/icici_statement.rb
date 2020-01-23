# == Schema Information
#
# Table name: icici_statements
#
#  id                  :bigint           not null, primary key
#  cheque_no           :string(255)
#  txn_date            :datetime
#  amount              :decimal(20, 10)
#  balance             :decimal(20, 10)
#  value_date          :datetime
#  transaction_type    :string(255)
#  transaction_id      :string(255)
#  request_id          :string(255)
#  bank_transaction_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :integer
#  remarks             :text(65535)
#  uuid                :string(36)
#

class IciciStatement < ApplicationRecord

  belongs_to :company
  belongs_to :bank_transaction, class_name: "IciciBankTransaction", optional: true

  validates_uniqueness_of :transaction_id, scope: [:company_id]

  default_scope { order(txn_date: :desc) }

  after_create do
    # since the last set of characters in the remarks will contain the Request ID
    request_id = self.remarks.split("/").last
    # removing any extra characters after the actual request ID
    request_id = request_id.split(" ").first
    self.update(request_id: request_id)
  end

end
