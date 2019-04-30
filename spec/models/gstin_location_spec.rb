# == Schema Information
#
# Table name: gstin_locations
#
#  id                :bigint(8)        not null, primary key
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
#  address           :text(65535)
#

require 'rails_helper'

RSpec.describe GstinLocation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
