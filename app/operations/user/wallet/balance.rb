class User::Wallet::Balance < User::Wallet::Base
  attr_accessor :selected_user

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def init
    if params.blank? or (params[:for_user].blank? and params[:for_user_id].blank?)
      self.selected_user = user
      return
    end
    self.selected_user = params[:for_user].blank?
    if selected_user.blank? and params[:for_user_id].present?
      op= User::Team::Index.new(user, params)
      users = op.run
      self.selected_user = (users.with_id(params[:for_user_id]).first rescue nil) if op.success? and users.present?
    end
  end

  def validate
    if selected_user.blank?
      add_message :error, 'User not found'
    end
  end

  def success
    self.selected_user.wallet.balance_value
  end

end