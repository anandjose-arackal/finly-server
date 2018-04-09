# == Schema Information
#
# Table name: travel_members
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  first_name         :string(255)
#  middle_name        :string(255)
#  last_name          :string(255)
#  child              :boolean
#  age                :integer
#  email              :string(255)
#  mobile_number      :string(255)
#  booking_id         :integer
#  booking_request_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class TravelMember < ActiveRecord::Base
  belongs_to :booking
  belongs_to :booking_request
end
