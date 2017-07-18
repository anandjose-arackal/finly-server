class Admin::KycProcesses::Users::Approve < Admin::KycProcesses::Users::Base

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
      unless [KycStatus.id_for(:processing)].include? individual_kyc.kyc_status_id
        add_message :error, "Error. KYC for #{individual_kyc.user.name} cannot be approved in this stage"
        return
      end
    end
  end

  def process
    self.individual_kycs.each do |individual_kyc|
      next_reviewer_presenter = Admin::KycProcesses::Users::NextAdminReviewPosition.(user, individual_kyc: individual_kyc)
      if next_reviewer_presenter.failure?
        add_message :error, next_reviewer_presenter.messages[:error]
        return
      end
      if next_reviewer_presenter.is_final?
        # No more reviewers
        individual_kyc.update(review_position: nil, kyc_status_id: KycStatus.id_for(:approved))

        track_params = {
            action_resource: user,
            action_id: IndividualKycTrackAction.id_for(:final_approve)
        }
        individual_kyc.tracks.create track_params
      else
        next_reviewer_position = next_reviewer_presenter.next_review_position
        individual_kyc.update(kyc_status_id: KycStatus.id_for(:processing), review_position: next_reviewer_position)

        track_params = {
            action_resource: user,
            action_id: IndividualKycTrackAction.id_for(:approve)
        }
        individual_kyc.tracks.create track_params
      end
    end
  end

end