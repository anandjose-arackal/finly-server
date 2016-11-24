# == Schema Information
#
# Table name: card_transactions
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  card_id               :integer
#  merchant_name         :string(255)
#  transaction_type      :string(255)
#  post_data             :text(65535)
#  transaction_amount_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  reference_id          :string(255)
#  auth_transaction_id   :string(255)
#  transaction_mode      :string(255)
#  itzcash_merchant_key  :string(255)
#  merchant_city         :string(255)
#  response_code         :string(255)
#  serial_id             :string(255)
#  product_code          :string(255)
#  transaction_timestamp :datetime
#  expensed              :boolean          default(TRUE)
#  error_message         :text(65535)
#  billing_amount_id     :integer
#

class CardTransaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :card

  belongs_to :expense

  belongs_to :transaction_amount, class_name: "Amount", dependent: :destroy
  belongs_to :card_amount, class_name: "Amount", dependent: :destroy
  belongs_to :billing_amount, class_name: "Amount", dependent: :destroy

  delegate :transaction_amount_value, to: :transaction_amount
  delegate :billing_amount_value, to: :billing_amount

  accepts_nested_attributes_for :transaction_amount
  accepts_nested_attributes_for :card_amount
  accepts_nested_attributes_for :billing_amount

  scope :debits, -> {where transaction_type: "Debit"}
  scope :credits, -> {where transaction_type: "Credit"}

end
