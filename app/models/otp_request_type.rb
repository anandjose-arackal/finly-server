# == Schema Information
#
# Table name: otp_request_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OtpRequestType < ActiveRecord::Base

  TYPES = {
      user_activation: 1,
      user_verification: 2,
      set_or_forgot_password: 3
  }

  def self.id_for(type)
    TYPES[type]
  end

end
