class KycProcess::User::Base < BaseOperation
  attr_accessor :individual_kyc,:update_user

  def pre_validate
    if user.blank? or params&.dig(:id).blank?
      add_message :error, 'User not found'
    end
  end

  def init
    self.update_user = User::Show.(user, params)&.selected_user
    return if self.update_user.blank?
    self.individual_kyc = self.update_user.individual_kyc
    self.kyc_params = kyc_strong_params
  end

  # def pre_validate
  #   if user.blank?
  #     add_message :error, 'User not found'
  #     return
  #   end
  # end
  #
  # def init
  #   self.individual_kyc = user.individual_kyc
  # end

  def validate
    if self.individual_kyc.blank?
      add_message :error, 'User not found'
    end
  end

end