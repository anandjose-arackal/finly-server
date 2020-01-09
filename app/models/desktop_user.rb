# == Schema Information
#
# Table name: desktop_users
#
#  id         :integer          not null, primary key
#  email      :string(255)      not null
#  country    :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DesktopUser < ApplicationRecord

  validates :email, presence: true, format: Constants::VALID_EMAIL_FORMAT
  validates :country, presence: true

end
