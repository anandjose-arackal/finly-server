class User::PrepaidCard::Credit < User::PrepaidCard::Base
  attr_accessor :amount, :credit_presenter

  def authorized_user_types
    [:finance_manager, :admin]
  end

  def pre_validate
    super
    if params.blank? or params[:amount].blank?
      messages[:error] << 'Amount cannot be blank'
      return
    end
    if params[:password].blank?
      messages[:error] << 'You need to provide your password to load the funds'
    elsif not user.valid_password?(params[:password])
      messages[:error] << 'Invalid Password!'
    end
  end

  def init
    super
    self.amount = params[:amount].to_i rescue nil
  end

  def validate
    super
    if self.amount.blank? or self.amount <= 0
      messages[:error] << 'Amount cannot be less than or equal to 0'
    end
  end

  def process
    self.credit_presenter = ItzCash::Credit.(selected_user, params)
    if credit_presenter.failure?
      messages[:error] = credit_presenter.messages[:error]
    end
  end

  def post_process
    if self.credit_presenter.present? and self.credit_presenter.success?
      messages[:success] << "Successfully credited the card with ₹#{amount}"
    end
  end

  def success
    self.credit_presenter.messages[:success] = messages[:success] if self.credit_presenter.present?
    self.credit_presenter
  end

end