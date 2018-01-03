class KycProcess::User::Submit < KycProcess::User::Base

  def validate
    super
    return if has_errors?
    unless self.individual_kyc.can_submit?
      add_message :error, 'Please complete your KYC Details before submitting'
      return
    end
    validate_user_profile
  end

  def validate_user_profile
    user_profile = self.individual_kyc.user.profile
    unless user_profile.date_of_birth.present?
      add_message :error, 'Date of birth cannot be blank'
    end
    unless user_profile.gender.present?
      add_message :error, 'Gender has not been selected'
    end
    unless user_profile.address_1.present?
      add_message :error, 'Address 1 cannot be blank'
    end
    unless user_profile.address_2.present?
      add_message :error, 'Address 2 cannot be blank'
    end
    unless user_profile.city.present?
      add_message :error, 'City cannot be blank'
    end
    unless user_profile.state_id.present?
      add_message :error, 'State has not been selected'
    end
    unless user_profile.pin_code.present?
      add_message :error, 'Pin Code cannot be blank'
    end
  end

  def process
    review_pos = 0
    unless self.individual_kyc.user.cards.present?
      review_pos = nil
    end
    unless self.individual_kyc.update(kyc_status_id: KycStatus.id_for(:submitted), review_position: review_pos, submitted_on: DateTime.now)
      add_message :error, self.individual_kyc.errors.full_messages
      return
    end
    track_params = {
        action_resource: user,
        action_id: IndividualKycTrackAction.id_for(:submit)
    }
    self.individual_kyc.tracks.create track_params
  end

end