class User::Wallet::Balance < User::Wallet::Base
  attr_accessor :selected_user

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
    end
  end

  def init
    self.params = {} if self.params.blank?
    if params.blank? or (params[:for_user].blank? and params[:user].blank? and params[:for_user_id].blank? and
        params[:user_id].blank? and params[:id].blank?)
      self.selected_user = user
      return
    elsif params[:for_user].present? or params[:user].present?
      self.selected_user = (params[:for_user] or params[:user])
    end
    # self.selected_user = params[:for_user].blank?
    if selected_user.blank? and (params[:for_user_id].present? or params[:user_id].present? or params[:id].present?)
      id = (params[:for_user_id] or params[:user_id] or params[:id])
      op= User::Team::Index.new(user, params)
      users = op.run
      self.selected_user = (users.with_id(id).first rescue nil) if op.success? and users.present?
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