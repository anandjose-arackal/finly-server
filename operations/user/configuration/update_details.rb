class User::Configuration::UpdateDetails < BaseOperation

  attr_accessor :details_params

  def pre_validate
    if user.blank? or params.blank?
      errors << "No user or params passed."
    end
  end

  def validate
    if details_params[:name].blank?
      errors << "Name cannot be blank."
      return false
    end
    if details_params[:mobile_number].blank?
      errors << "Mobile number cannot be blank."
    end
  end


  def process
    unless user.update(details_params)
      errors << user.errors.full_messages
    end
  end

  def success
    self.user
  end

  private

  def details_params
    params.require(:user).permit(:name, :mobile_number, :active)
  end
end