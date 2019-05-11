FactoryBot.define do
  factory :tax_per_item do
    document { nil }
    tax_rate { nil }
    cgst_id { 1 }
    sgst_id { 1 }
    igst_id { 1 }
  end
end
