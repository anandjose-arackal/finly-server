class Admin::Cards::AssignStatus < Admin::Cards::Base
  attr_accessor :selected_card, :is_assigned, :is_upgraded, :status_message

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, 'Invalid parameters'
    end
  end

  def init
    id = params[:id] || params[:card_id] || params[:card]
    self.selected_card = Card.find_by(id: id)
  end

  def validate
    if self.selected_card.blank?
      add_message :error, 'Card not found'
    end
  end

  def process
    unless selected_card.assigned?
      self.status_message = 'Card not assigned'
      return
    end
    details = ItzCash::AccountDetails.(user, card: selected_card)
    unless details.success?
      self.status_message = details.messages[:error]
      return
    end
    # Check if assigned
    self.is_assigned = details.assigned?
    unless is_assigned
      if details.distributor_id != 'D000000000'
        self.status_message = 'd_code assign mismatch'
        return
      end
      self.status_message = 'Card unassigned'
      return
    end
    # Check if upgraded
    self.is_upgraded = details.upgraded?
    unless self.is_upgraded
      add_message :error, 'Card assigned as ASC'
    end
  end

  def post_process
    update_card_assign_requests
    update_individual_kyc_requests
  end

  def update_card_assign_requests
    if is_upgraded
      if CardStatus.ids_for([:unassigned, :assign_requested, :assigned, :upgrade_requested]).include? card.card_status_id
        card.update(card_status_id: CardStatus.id_for(:upgraded))
        upgradable_requests = card.card_assign_requests.assignable
        upgradable_requests&.each do |assign_request|
          assign_request.update(status_id: CardAssignRequestStatus.id_for(:assigned_and_upgraded))
          track_params = {
              action_id: CardAssignRequestTrackAction.id_for(:assigned_upgraded)
          }
          assign_request.tracks.create track_params
        end
      end
    elsif is_assigned
      if CardStatus.ids_for([:unassigned, :assign_requested, :assigned, :upgrade_requested]).include? card.card_status_id
        card.update(card_status_id: CardStatus.id_for(:assigned))
        upgradable_requests = card.card_assign_requests.assignable
        upgradable_requests&.each do |assign_request|
          assign_request.update(status_id: CardAssignRequestStatus.id_for(:assigned))
          track_params = {
              action_id: CardAssignRequestTrackAction.id_for(:assigned)
          }
          assign_request.tracks.create track_params
        end
      end
    end
  end

  def update_individual_kyc_requests
    return unless is_upgraded
    kyc = card.user.individual_kyc
    return unless kyc.completed?
    kyc.update(kyc_status_id: KycStatus.id_for(:completed))
    track_params = {
        action_id: IndividualKycTrackAction.id_for(:upgraded)
    }
    kyc.tracks.create track_params
  end

  def success
    params[:card] = self.selected_card
    params[:is_assigned] = self.is_assigned
    params[:is_upgraded] = self.is_upgraded
    params[:status_message] = self.status_message
    Admin::Cards::AssignStatus::SuccessPresenter.new(user, params, messages)
  end

  class Admin::Cards::AssignStatus::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :card, :is_assigned, :is_upgraded, :status_message

    def init
      self.card = params[:card]
      self.is_assigned = params[:is_assigned]
      self.is_upgraded = params[:is_upgraded]
      self.status_message = params[:status_message]
    end

  end

end