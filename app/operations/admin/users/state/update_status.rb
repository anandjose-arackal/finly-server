# operation that updates the status of a particular user - active or inactive

class Admin::Users::State::UpdateStatus < Admin::Users::Base

  attr_accessor :selected_user, :update_params

  def pre_validate
    super()
    if user.blank? || params.blank?
      add_message :error, "Invalid params, try again"
    end
  end

  def init
    id = params[:id] || params[:user_id]
    self.selected_user = User.find_by(id: id)
    self.update_params = user_status_params
  end

  def process
    unless selected_user.update(update_params)
      add_message :error, selected_user.errors.full_messages
    end
  end

  def post_process
    add_message :success, "User status updated"
  end

  private

  def user_status_params
    params.require(:user).permit(:active)
  end
end