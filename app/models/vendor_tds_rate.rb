# == Schema Information
#
# Table name: vendor_tds_rates
#
#  id                :bigint(8)        not null, primary key
#  vendor_id         :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  tds_rates_list_id :integer
#

class VendorTdsRate < ApplicationRecord
  belongs_to :vendor, foreign_key: :vendor_id, class_name: "YesBankVendor", optional: true
  belongs_to :tds_rate, class_name: "TdsRatesList", foreign_key: :tds_rates_list_id, optional: true
end
