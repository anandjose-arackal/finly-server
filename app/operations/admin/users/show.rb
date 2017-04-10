class Admin::Users::Show < Admin::Users::Base

  attr_accessor :selected_user

  def init
    id = params[:id] || params[:user_id]
    self.selected_user = User.find_by(id: id)
  end

  def success
    Admin::Users::Base::UserPresenter.new(user, {selected_user: selected_user}, messages)
  end
end