# == Schema Information
#
# Table name: tax_per_items
#
#  id            :bigint           not null, primary key
#  document_type :string(255)
#  document_id   :bigint
#  tax_rate_type :string(255)
#  tax_rate_id   :bigint
#  cgst_id       :integer
#  sgst_id       :integer
#  igst_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class TaxPerItem < ApplicationRecord
  belongs_to :document
  belongs_to :tax_rate
end
