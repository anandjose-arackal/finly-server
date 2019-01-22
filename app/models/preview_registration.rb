# == Schema Information
#
# Table name: preview_registrations
#
#  id                 :integer          not null, primary key
#  email              :string(255)
#  company            :text(65535)
#  phone_number       :string(255)
#  name               :text(65535)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  source             :text(65535)
#  source_description :text(65535)
#  referrer           :string(255)
#

class PreviewRegistration < ApplicationRecord

  validates :email, presence: true, format: { allow_blank: true, with: Constants::VALID_EMAIL_FORMAT}
  validates :phone_number, length: {allow_blank: true, is: 10}, format: {allow_blank: true, with: Constants::VALID_MOBILE_NUMBER}

end
