class User::Configuration::UpdateDetails < BaseOperation

  attr_accessor :details_params

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed."
    end
  end

  def validate
    if details_params[:name].blank?
      messages[:error] << "Name cannot be blank."
      return false
    end
    if details_params[:mobile_number].blank?
      messages[:error] << "Mobile number cannot be blank."
    end
  end


  def process
    unless user.update(details_params)
      messages[:error] << user.errors.full_messages
    end
  end

  private

  def details_params
    params.require(:user).permit(:name, :mobile_number)
  end
end