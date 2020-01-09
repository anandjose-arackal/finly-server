# == Schema Information
#
# Table name: invoice_number_config_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class InvoiceNumberConfigType < ApplicationRecord

  include Seedable

  def self.values
    [
        :tax_invoice,
        :advance,
        :credit_note,
        :debit_note
    ]
  end
end
