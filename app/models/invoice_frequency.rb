class InvoiceFrequency < ApplicationRecord

  belongs_to :period, optional: true

end
