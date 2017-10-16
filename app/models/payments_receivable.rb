class PaymentsReceivable < ActiveRecord::Base
  belongs_to :customer
  belongs_to :amount
  belongs_to :company
end
