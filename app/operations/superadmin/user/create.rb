class Superadmin::User::Create < Superadmin::User::Base

  attr_accessor :company, :new_user

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "Invalid parameters"
    end
  end

  def init
    self.company = Company.find_by(id: params[:id] || params[:company_id])
  end

  def authorize
    unless Constants::SUPERADMIN_ACCOUNTS.include?(user.email)
      raise_unauthorized_exception
    end
    unless company
      raise_unauthorized_exception
    end
  end

  def validate

  end

  def process
    self.new_user = company.users.build(new_user_params)
    new_user.skip_confirmation_notification!
    if new_user.save
      new_user.activate
      messages[:success] << "New user created!"
    else
      messages[:error] = new_user.errors.full_messages.to_sentence
    end
  end

  def success
    Company::Base::CompanyPresenter.new(new_user, company: company)
  end

  def post_process
    # if the new_user has a card, activate that card
    if new_user.cards.present?
      new_user.cards.first.update_attributes(active: true)
    end
  end

  private

end
