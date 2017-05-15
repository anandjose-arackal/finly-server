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
    self.card_program = CardProgram.find_by(id: [:card_program_id])
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
    users.each do |user|
      if user.cards.with_card_program(self.card_program_id).present?
        c = user.cards.with_card_program(self.card_program_id).first

      end
    end
  end

end