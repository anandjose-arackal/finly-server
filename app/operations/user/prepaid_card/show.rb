class User::PrepaidCard::Show < User::PrepaidCard::Base
  attr_accessor :account_details

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin]
  end

  def pre_validate
    super
    return if has_errors?
    if params[:card_id].blank?
      add_message :error, 'Card not found'
    end
  end

  def validate
    super
    return if has_errors?
    if selected_user.cards.with_id(params[:card_id]).blank?
      add_message :error, 'Card not found'
    end
  end

  def process
    self.account_details = ItzCash::AccountDetails.(selected_user, params)
    if account_details.failure?
      messages[:error] = account_details.messages[:error]
    end
  end

  def success
    self.account_details
  end

end