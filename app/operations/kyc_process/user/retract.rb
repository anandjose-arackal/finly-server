class KycProcess::User::Retract < KycProcess::User::Base

  def validate
    super
    return if has_errors?
    unless self.individual_kyc.retractable?
      add_message :error, 'KYC cannot be retracted at this stage'
    end
  end

  def process
    unless self.individual_kyc.update(kyc_status_id: KycStatus.id_for(:retracted), review_position: nil, submitted_on: nil)
      add_message :error, self.individual_kyc.errors.full_messages
      return
    end
    track_params = {
        action_resource: user,
        action_id: IndividualKycTrackAction.id_for(:retract)
    }
    self.individual_kyc.tracks.create track_params
  end

end