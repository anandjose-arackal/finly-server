class KycProcess::User::Base < BaseOperation
  attr_accessor :individual_kyc

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.individual_kyc = user.individual_kyc
  end

  def validate
    if self.individual_kyc.blank?
      add_message :error, 'User not found'
    end
  end

end