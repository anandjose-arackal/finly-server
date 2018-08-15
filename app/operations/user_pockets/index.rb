class UserPockets::Index < UserPockets::Base

  attr_accessor :pockets,:selected_user

  class UserPockets::Index::PocketsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :pockets

    def init
      self.pockets = params[:pockets]
    end

  end

  def init
    selected_user_id = params[:id] || params[:selected_user_id]
    self.selected_user = user.company.users.find_by(id: selected_user_id)
    if selected_user.blank?
      self.selected_user = user
    end
  end

  def process
    self.pockets = self.selected_user.user_pockets
  end

  def success
    params[:pockets] = self.pockets
    UserPockets::Index::PocketsPresenter.new(user, params, messages)
  end
end