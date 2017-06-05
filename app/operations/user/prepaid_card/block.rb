class User::PrepaidCard::Block < User::PrepaidCard::Base
  attr_accessor :block_presenter, :card

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    super
    return if has_errors?
    require_password_validation = true
    unless params[:validate_password].nil?
      require_password_validation = !!params[:validate_password]
      end
    if require_password_validation
      if params[:password].blank?
        add_message :error, 'You need to provide your password for disabling the card'
      elsif not user.valid_password?(params[:password])
        add_message :error, 'Invalid Password!'
      end
    end
    if params[:card_id].blank?
      add_message :error, 'Card not found'
    end
  end

  def init
    super()
    self.card = selected_user.cards.with_id(card_id).first rescue nil
  end

  def validate
    super
    return if has_errors?
    if self.card_id.blank?
      add_message :error, 'Card not found'
      return
    end
    if self.card.blank?
      add_message :error, 'Card not found'
    end
  end

  def process
    self.block_presenter = ItzCash::Block.(selected_user, card_id: self.card_id)
    if block_presenter.failure?
      add_message :error, block_presenter.messages[:error]
    end
  end

  def post_process
    return unless success?
    role = nil
    role = user_role_id unless params[:user_deactivation]
    update_params = {active: false,
                     disabled_by_role_id: role,
                     disabled_by_user_id: user.id,
                     disable_note: (params[:disable_note] or params[:reason])}
    if self.block_presenter.present? and self.block_presenter.success?
      card.update_attributes(update_params)
      add_message :success, 'Successfully blocked the card!'
    end
  end

  def success
    self.block_presenter.messages[:success] = messages[:success] if self.block_presenter.present?
    self.block_presenter
  end

  protected
  def user_role_id
    # todo update from view to user relation with the user
    if personal_view?
      return UserRole.id_for(:employee)
    elsif manager_view?
      return UserRole.id_for(:manager)
    elsif finance_view?
      return UserRole.id_for(:finance_manager)
    elsif admin_view?
      return UserRole.id_for(:admin)
    end
  end

end
