class UserPockets::AssignablePockets < UserPockets::Base

  attr_accessor :pockets, :existing_pockets

  def init
    self.existing_pockets = user.user_pockets
  end

  def process
    pocket_ids = user.company.user_pockets.pluck(:id) - self.existing_pockets.pluck(:id)
    self.pockets = UserPocket.with_id(pocket_ids)
  end

  def success
    params[:pockets] = self.pockets
  end

  class UserPockets::AssignablePockets::PocketsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :pockets

    def init
      self.pockets = params[:pockets]
    end
  end
end