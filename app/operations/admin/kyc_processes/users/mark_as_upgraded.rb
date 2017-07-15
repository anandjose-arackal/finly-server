class Admin::KycProcesses::Users::MarkAsUpgraded < Admin::KycProcesses::Users::Base

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
      unless [KycStatus.id_for(:processing), KycStatus.id_for(:approved)].include? individual_kyc.kyc_status_id
        add_message :error, "Error. User #{individual_kyc.user.name} cannot be approved in this stage"
        return
      end
    end
  end

  def process
    self.individual_kycs.each do |individual_kyc|
      individual_kyc.update(review_position: nil, kyc_status_id: KycStatus.id_for(:completed), upgraded_by_resource: user, upgraded_on: DateTime.now)
      individual_kyc.card.update(card_status_id: CardStatus.id_for(:upgraded))
      track_params = {
          action_resource: user,
          action_id: IndividualKycTrackAction.id_for(:upgraded)
      }
      individual_kyc.tracks.create track_params
    end
  end

end