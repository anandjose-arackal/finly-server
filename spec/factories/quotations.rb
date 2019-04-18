# == Schema Information
#
# Table name: quotations
#
#  id                      :bigint(8)        not null, primary key
#  vendor_name             :string(255)
#  vendor_location         :string(255)
#  estimated_delivery_time :string(255)
#  total_amount            :decimal(20, 2)
#  advance_amount          :decimal(20, 2)
#  credit_period           :string(255)
#  note                    :text(65535)
#  selected                :boolean          default(FALSE)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  purchase_order_id       :integer
#  is_deleted              :boolean
#  deleted_at              :datetime
#  quotation_number        :string(255)
#

FactoryBot.define do
  factory :quotation do
    vendor_name { "MyString" }
    vendor_location { "MyString" }
    estimated_delivery_time { "MyString" }
    total_amount { "MyString" }
    advance_amount { "MyString" }
    credit_period { "MyString" }
    note { "MyText" }
    selected { false }
  end
end
