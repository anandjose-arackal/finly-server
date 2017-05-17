class UserTeam::BatchUpdate::Restriction < UserTeam::BatchUpdate::Base
  attr_accessor :card_program

  def pre_validate
    super
    return if has_errors?
    unless params&.dig(:card_program_id).present?
      add_message :error, 'Card not found'
      return
    end
  end

  def init
    super
    self.card_program = CardProgram.find_by(id: params[:card_program_id])
  end

  def validate
    super
    return if has_errors?
    unless card_program.present?
      add_message :error, 'Card not found'
      return
    end
    unless card_program.spend_restrictions
      add_message :error, 'You cannot set restrictions on the following Cards'
    end
  end

  def process
    params[:user_ids] = users.pluck(:id)
    params[:card_program] = self.card_program
    UserTeam::BatchUpdate::Restriction::BackgroundUpdate.(user, params)
  end

  class UserTeam::BatchUpdate::Restriction::BackgroundUpdate < BackgroundOperation
    attr_accessor :users, :card_program

    def pre_validate
      unless params&.dig(:user_ids).present?
        add_message :error, 'User not found'
        return
      end
      unless params&.dig(:card_program).present?
        add_message :error, 'Card not found'
        return
      end
    end

    def init
      self.users = User.with_id(params[:user_ids])
      self.card_program = params[:card_program]
    end

    def validate
      if users.blank?
        add_message :error, 'User not found'
      end
      if card_program.blank?
        add_message :error, 'Card not found'
      end
    end

    def process
      users.each do |selected_user|
        card = selected_user.cards.with_card_program(self.card_program)&.first
        if card
          param = params
          param[:user] = selected_user
          param[:card] = card
          Card::Restriction::Update.(user, param)
        end
      end
    end

  end

end