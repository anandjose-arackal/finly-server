require 'bcrypt'

class SignedupUser < ActiveRecord::Base
  attr_accessor :password
  before_save :encrypt_password
  after_save :clear_password

  validates :email, presence: true, format: { allow_blank: true, with: Constants::VALID_EMAIL_FORMAT}
  validates :mobile_number, length: {allow_blank: true, is: 10}, format: {allow_blank: true, with: Constants::VALID_MOBILE_NUMBER}


  def encrypt_password
    self.encrypted_password = BCrypt::Password.create(password)
  end

  def clear_password
    self.password = nil
  end
end
