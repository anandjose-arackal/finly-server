class Card::Restriction::Destroy < User::Base

  attr_accessor :card_limit

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank? or params.blank?
      add_message :error, 'Invalid input, please try again'
      return
    end
    if params[:id].blank? and params[:user_id].blank?
      add_message :error, 'User not found'
      return
    end
    if params[:card_id].blank?
      add_message :error, 'Card not found'
    end
    if params[:limit_id].blank?
      add_message :error, 'Restriction not found'
    end
  end

  def init
    selected_user = User::Index.(user, params).team.with_id((params[:id] or params[:user_id])).first rescue nil
    return if selected_user.blank?
    selected_card = selected_user.cards.with_id(card_id: params[:card_id])
    return if selected_card.blank?
    self.card_limit = selected_card.card_restriction.card_limits.with_id(params[:limit_id]).first rescue nil
  end

  def validate
    unless card_limit
      add_message :error, 'Restriction not found'
    end
  end

  def process
    unless card_limit.destroy
      add_message :error, card_limit.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Updated successfully'
  end


end