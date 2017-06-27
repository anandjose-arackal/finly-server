class User::PrepaidCard::Base < BaseOperation
  attr_accessor :card

  STATUS = {block: 0, unblock: 1}

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
    if params.blank?
      add_message :error, 'Error loading configuration'
    end
  end

  def init
    self.params = {} if self.params.blank?

    self.card = params[:card]
    if self.card.blank? and params[:card_id].present?
      card_id = params[:card_id]
      cards = Card::Index.(user, params)
      self.card = cards.cards.find_by(id: card_id)
    end

    # self.selected_user = params[:user]
    # return unless self.selected_user.blank?
    # selected_user_id = (params[:id] or params[:user_id])
    # if personal_view? or selected_user_id == user.id
    #   self.selected_user = user
    # else
    #   operation = User::Team::Index.new(user, params)
    #   result = operation.run
    #   if operation.success?
    #     self.selected_user = result.with_id(selected_user_id).first rescue nil
    #     messages[:error] << 'User not found' if self.selected_user.blank?
    #   else
    #     messages[:error] = operation.messages[:error]
    #   end
    # end
  end

  def validate
    if self.card.blank?
      add_message :error, 'Card not found'
    end
  end

end