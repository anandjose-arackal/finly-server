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
#  gender             :string(255)
#

class TravelMember < ApplicationRecord

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :mobile_number, format: {allow_blank: true, with: Constants::VALID_MOBILE_NUMBER}
  validates :email, format: {allow_blank: true, with: Constants::VALID_EMAIL_FORMAT}
  # validates :age, presence: true
  # validates :mobile_number, presence: true

  belongs_to :booking, optional: true
  belongs_to :booking_request, optional: true

  scope :without_id_nil, -> { where.not id: nil }
end
