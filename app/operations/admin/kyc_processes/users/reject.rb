class Admin::KycProcesses::Users::Reject < Admin::KycProcesses::Users::Base

  def validate
    super
    return if has_errors?
    self.individual_kycs.each do |individual_kyc|
      reviewer_presenter = Admin::KycProcesses::Users::IsReviewer.(user, individual_kyc: individual_kyc, admin_user: user)
      unless reviewer_presenter.success?
        add_message :error, reviewer_presenter.messages[:error]
        return
      end
      unless reviewer_presenter.is_reviewer
        add_message :error, 'You are not the assigned reviewer for this request'
        return
      end
      unless [KycStatus.id_for(:submitted), KycStatus.id_for(:processing), KycStatus.id_for(:approved)].include? individual_kyc.kyc_status_id
        add_message :error, "Error. User #{individual_kyc.user.name} cannot be rejected in this stage"
        return
      end
    end
  end

  def process
    self.individual_kycs.each do |individual_kyc|
      individual_kyc.update(review_position: nil, kyc_status_id: KycStatus.id_for(:rejected), admin_note: params[:admin_note])
      track_params = {
          action_resource: user,
          action_id: IndividualKycTrackAction.id_for(:reject),
          note: params[:admin_note],
          company_id: individual_kyc.company_id
      }
      individual_kyc.tracks.create track_params
    end
  end

  def post_process
    self.individual_kycs.each do |individual_kyc|
      if individual_kyc.admin_note.present?
        reason = "REASON: #{individual_kyc.admin_note}"
      else
        reason = ""
      end
      op = Sms::Send.(individual_kyc.user, user: individual_kyc.user, message: "Your Finly Prepaid Card KYC has been rejected #{reason}. Pls re-upload KYC via Finly app -Finly Team")
    end
  end

end