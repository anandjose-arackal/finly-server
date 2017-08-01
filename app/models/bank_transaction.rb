class BankTransaction < ActiveRecord::Base
  belongs_to :amount
  belongs_to :company
end
