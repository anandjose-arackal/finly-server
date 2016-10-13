# == Schema Information
#
# Table name: preview_registrations
#
#  id           :integer          not null, primary key
#  email        :string(255)
#  company      :text(65535)
#  phone_number :string(255)
#  name         :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#



class PreviewRegistration < ActiveRecord::Base

  validates :email, presence: true, format: Constants::VALID_EMAIL_FORMAT
  validates :mobile_number, presence: true, length: {is: 10}, format: Constants::VALID_MOBILE_NUMBER

end
