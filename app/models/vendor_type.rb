# == Schema Information
#
# Table name: vendor_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  company_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class VendorType < ApplicationRecord
  belongs_to :company, optional: true
end
