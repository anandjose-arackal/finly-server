# action to update a particular user's details.

class User::Configuration::UpdateDetails < BaseOperation

  attr_accessor :details_params, :being_updated_user

  def authorized_user_types
    [:employee]
  end

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "No user or params passed."
    end
  end

  def init
    self.being_updated_user = user.company.users.find_by(id: params[:id])
  end

  def authorize
    unless user.id == being_updated_user.id
      messages[:error] << "You are not authorized to change these details."
    end
  end

  def validate
    if details_params[:name].blank?
      messages[:error] << "Name cannot be blank."
      return false
    end
  end


  def process
    unless user.update(details_params)
      messages[:error] << user.errors.full_messages
    end
  end

  def post_process
    messages[:success] << "Details updated."
  end

  private

  def details_params
    params.require(:user).permit(:name, :mobile_number)
  end
end