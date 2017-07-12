class Card::AssignRequest::Create < Card::AssignRequest::Base
  attr_accessor :selected_user, :card, :card_program, :card_assign_request

  def authorized_user_types
    :company_admin
  end

  def pre_validate
    if params&.dig(:user_id).blank?
      add_message :error, 'User not found'
      return
    end
    if params&.dig(:card_id).blank?
      add_message :error, 'Card not found'
      return
    end
    if params&.dig(:card_program_id).blank?
      add_message :error, 'Card Program cannot be blank'
      return
    end
  end

  def init
    user_presenter = User::Show.(user, params)
    unless user_presenter&.success?
      add_message :error, user_presenter.messages[:error]
      return
    end
    self.selected_user = user_presenter.selected_user
    cards_presenter = Card::Unassigned.(user, params)
    unless cards_presenter&.success?
      add_message :error, user_presenter.messages[:error]
      return
    end
    self.card = cards_presenter.unassigned_cards.find_by(id: params[:card_id])
    self.card_program = CardProgram.find_by(id: params[:card_program_id])
  end

  def validate
    if self.selected_user.blank?
      add_message :error, 'User not found'
      return
    end
    if self.card.blank?
      add_message :error, 'User not found'
      return
    end
    if self.card_program.blank?
      add_message :error, 'Card Program cannot be blank'
      return
    end
    if selected_user.cards.with_card_program(self.card_program.id).present?
      add_message :error, "An #{card_program.name} card has already been assigned to the user"
      return
    end
    unless self.card.unassigned?
      add_message :error, 'Card has already been assigned to another user'
    end
  end

  def process
    review_workflow = AdminReviewWorkflow.workflow_for(:assign_card)
    request_param = {
        card_id: self.card.id,
        card_program_id: self.card_program.id,
        status_id: CardAssignRequestStatus.id_for(:processing),
        card_owner_id: selected_user.id,
        initiating_resource: self.user,
        admin_review_workflow: review_workflow,
        review_position: review_workflow.levels.first.position
    }
    self.card_assign_request = card.card_assign_requests.new request_param
    unless self.card_assign_request.save
      add_message :error, self.card_assign_request.errors.full_messages
    end
    card.update(user_id: selected_user.id, card_program_id: card_program.id, card_status_id: CardStatus.id_for(:assign_requested))

    track_params = {
        action_resource: user,
        action_id: CardAssignRequestTrackAction.id_for(:submit)
    }
    self.card_assign_request.tracks.create track_params
  end

  def success
    params[:selected_user] = self.selected_user
    params[:card] = self.card
    params[:card_program] = self.card_program
    params[:card_assign_request] = self.card_assign_request
    Card::AssignRequest::Create::SuccessPresenter.new(user, params, messages)
  end

  class Card::AssignRequest::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :selected_user, :card, :card_program, :card_assign_request

    def init
      self.selected_user = params[:selected_user]
      self.card = params[:card]
      self.card_program = params[:card_program]
      self.card_assign_request = params[:card_assign_request]
    end

  end

end