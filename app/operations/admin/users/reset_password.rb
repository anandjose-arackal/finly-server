class Admin::Users::ResetPassword < Admin::Users::Base

  attr_accessor :selected_user, :company

  def init
    id = params[:id] || params[:user_id]
    self.selected_user = User.find_by(id: id)
    self.company = self.selected_user.company
  end

  def process
    # set the default password for this user as true
    unless selected_user.update(default_password: true)
      add_message :error, selected_user.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Password reset successfully!"
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end
end