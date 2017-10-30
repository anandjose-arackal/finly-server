# == Schema Information
#
# Table name: invoices
#
#  id               :integer          not null, primary key
#  address_id       :integer
#  date             :date
#  due_date         :date
#  invoice_number   :string(255)
#  SGST             :decimal(10, )
#  CGST             :decimal(10, )
#  IGST             :decimal(10, )
#  tax_type_id      :integer
#  discount         :decimal(10, )
#  discount_type_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Invoice < ActiveRecord::Base
  belongs_to :address
end
