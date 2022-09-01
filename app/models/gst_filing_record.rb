class GstFilingRecord < ApplicationRecord
  belongs_to :company
  belongs_to :yes_bank_vendor
  belongs_to :gstin_location
end
