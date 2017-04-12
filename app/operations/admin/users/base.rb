class Admin::Users::Base < Admin::Base

  attr_accessor :selected_user

  class Admin::Users::Base::UserPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :created_user, :selected_user, :cards

    def init
      self.created_user = params[:created_user]
      self.selected_user = params[:selected_user]
      self.cards = selected_user.cards
    end

  end
end
