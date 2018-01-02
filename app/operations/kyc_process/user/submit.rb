class KycProcess::User::Submit < KycProcess::User::Base

  def validate
    super
    return if has_errors?
    unless self.individual_kyc.can_submit?
      add_message :error, 'Please complete your KYC Details before submitting'
      return
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