class TaxPerItem < ApplicationRecord
  belongs_to :document
  belongs_to :tax_rate
end
