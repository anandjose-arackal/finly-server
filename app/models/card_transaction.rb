# == Schema Information
#
# Table name: card_transactions
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  card_id                   :integer
#  channel                   :string(255)
#  merchant_category_code    :string(255)
#  merchant_id               :integer
#  merchant_name             :string(255)
#  network                   :string(255)
#  terminal_id               :integer
#  trace_number              :string(255)
#  transaction_currency_code :string(255)
#  transaction_type          :string(255)
#  card_currency_code        :string(255)
#  post_data                 :text(65535)
#  bank_network              :string(255)
#  transaction_amount_id     :integer
#  card_amount_id            :integer
#  date                      :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  timestamp                 :datetime
#


class CardTransaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :card

  has_one :card_expense

  belongs_to :transaction_amount, class_name: "Amount", dependent: :destroy
  belongs_to :card_amount, class_name: "Amount", dependent: :destroy

  delegate :transaction_amount_value, to: :transaction_amount

  accepts_nested_attributes_for :transaction_amount
  accepts_nested_attributes_for :card_amount

end
