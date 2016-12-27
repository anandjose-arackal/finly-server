class User::PrepaidCard::Block < User::PrepaidCard::Base
  attr_accessor :block_presenter

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    super
    return if has_errors?
    if params[:password].blank?
      add_message :error, 'You need to provide your password for disabling the card'
    elsif not user.valid_password?(params[:password])
      add_message :error, 'Invalid Password!'
    end
  end

  def validate
    super
    return if has_errors?
    validate_status
  end

  def validate_status
    # unless selected_user.cards.first.active
    #   add_message :error, 'Card is already blocked'
    # end
  end

  def process
    self.block_presenter = ItzCash::Block.(selected_user, params)
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
                     disable_note: params[:disable_note]}
    selected_user.cards.first.update_attributes(update_params)
    if self.block_presenter.present? and self.block_presenter.success?
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
