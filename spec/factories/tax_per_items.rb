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

FactoryBot.define do
  factory :tax_per_item do
    document { nil }
    tax_rate { nil }
    cgst_id { 1 }
    sgst_id { 1 }
    igst_id { 1 }
  end
end
