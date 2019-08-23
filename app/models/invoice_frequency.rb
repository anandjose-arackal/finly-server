class InvoiceFrequency < ApplicationRecord

  belongs_to :period, optional: true

  validates :period, :number, presence: true
end
