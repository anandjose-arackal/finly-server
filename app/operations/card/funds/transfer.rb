class Card::Funds::Transfer < Cards::Funds::Base
  attr_accessor :to_user, :amount

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
      return
    end
    if user.cards.blank?
      messages[:error] << 'Card is not assigned to the user to transfer the funds'
    end
    if params.blank? or params[:to_user_id].blank? or params[:to_user].blank?
      messages[:error] << 'Card is not assigned to the user to receive the funds'
      return
    end
    if params[:password].blank?
      messages[:error] << 'You will have to provide your password to complete the transfer'
    end
    unless user.valid_password? params[:password]
      messages[:error] << 'Invalid password!'
    end
    if params[:amount].blank? or params[:amount].to_i <= 0
      messages[:error] << 'Transfer amount cannot be less than or equal to 0'
    end
  end

  def init
    self.to_user = params[:to_user]
    if to_user.blank? and params[:to_user_id].present?
      to_user_id = params[:to_user_id]
      to_u = User.with_id(to_user_id).first rescue nil
      if to_u.present? and to_u.company_id == user.company_id
        self.to_user = to_u
      end
    end
  end

  def validate
    if to_user.blank?
      messages[:error] << 'User not found'
      return
    end
    if to_user.cards.blank?
      messages[:error] << 'Card is not assigned to the user to receive the funds'
    end
  end

  def process
    debit_presenter = ItzCash::Debit.(user, amount: params[:amount])
    if debit_presenter.success?
      credit_presenter = ItzCash::Credit.(to_user, amount: params[:amount])
      unless credit_presenter.success?
        messages[:error] = credit_presenter.messages[:error]
      end
      return
    end
    messages[:error] = debit_presenter.messages[:error]
  end

  def post_process
    messages[:success] << 'Funds transferred successfully!'
  end

end
