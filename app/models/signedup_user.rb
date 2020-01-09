# == Schema Information
#
# Table name: signedup_users
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  mobile_number      :string(255)
#  email              :string(255)
#  encrypted_password :string(255)
#  products           :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  company_name       :string(255)
#

require 'bcrypt'

class SignedupUser < ApplicationRecord
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
