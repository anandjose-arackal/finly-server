# == Schema Information
#
# Table name: invoice_number_configs
#
#  id             :integer          not null, primary key
#  prefix         :string(255)      default("")
#  sequence_start :string(255)
#  company_id     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class InvoiceNumberConfig < ActiveRecord::Base

  belongs_to :company
end
