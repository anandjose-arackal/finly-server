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
#  location_id       :integer
#  state_id          :integer
#  poc_name          :string(255)
#  poc_mobile_number :string(255)
#  poc_email         :string(255)
#  poc_fax           :string(255)
#  poc_designation   :string(255)
#

class GstinLocation < ApplicationRecord
  belongs_to :gstin_master, foreign_key: :gstin_id
  belongs_to :state

  belongs_to :location, class_name: "BranchLocation"
end
