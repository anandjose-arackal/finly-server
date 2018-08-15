class UserPockets::Index < UserPockets::Base

  attr_accessor :pockets

  class UserPockets::Index::PocketsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :pockets

    def init
      self.pockets = params[:pockets]
    end

  end

  def init
    self.pockets = user.user_pockets
  end

  def success
    params[:pockets] = self.pockets
    UserPockets::Index::PocketsPresenter.new(user, params, messages)
  end
end