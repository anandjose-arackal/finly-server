# == Schema Information
#
# Table name: resource_requests
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  email              :string(255)
#  mobile_number      :string(255)
#  resource_file_name :string(255)
#

class ResourceRequest < ActiveRecord::Base

  validates :email, presence: true, format: { allow_blank: true, with: Constants::VALID_EMAIL_FORMAT}
  validates :mobile_number, presence: true
  validates :name, presence: true

end
