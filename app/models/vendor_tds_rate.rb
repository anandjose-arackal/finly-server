class VendorTdsRate < ApplicationRecord
  belongs_to :vendor, foreign_key: :vendor_id, class_name: "YesBankVendor"
  belongs_to :tds_rates, class_name: "TdsRatesList", foreign_key: :tds_rates_list_id
end
