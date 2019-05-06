# == Schema Information
#
# Table name: gstin_locations
#
#  id                :bigint           not null, primary key
#  vendor_id         :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  gstin_id          :integer
#  gstin             :string(255)
#  state_id          :integer
#  poc_name          :string(255)
#  poc_mobile_number :string(255)
#  poc_email         :string(255)
#  poc_fax           :string(255)
#  poc_designation   :string(255)
#  location          :string(255)
#

FactoryBot.define do
  factory :gstin_location do
    vendor_id { 1 }
    gstin { nil }
    gstin { "MyString" }
    location_id { 1 }
    state { nil }
    poc_name { "MyString" }
    poc_mobile_number { "MyString" }
    poc_email { "MyString" }
    poc_fax { "MyString" }
    poc_designation { "MyString" }
  end
end
