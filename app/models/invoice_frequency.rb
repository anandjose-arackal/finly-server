# == Schema Information
#
# Table name: invoice_frequencies
#
#  id         :bigint           not null, primary key
#  number     :integer
#  period_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class InvoiceFrequency < ApplicationRecord

  belongs_to :company, optional: true
  belongs_to :period, optional: true

end
