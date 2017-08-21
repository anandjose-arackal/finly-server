class DesktopUser < ActiveRecord::Base

  validates :email, presence: true, format: Constants::VALID_EMAIL_FORMAT
  validates :country, presence: true

end
