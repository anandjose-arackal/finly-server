class Admin::Users::Show < Admin::Users::Base

  attr_accessor :selected_user, :company

  def init
    id = params[:id] || params[:user_id]
    self.selected_user = User.find_by(id: id)
    self.company = self.selected_user.company
  end

  def success
    params[:selected_user] = selected_user
    Admin::Users::Base::UserPresenter.new(user, params, messages)
  end
end