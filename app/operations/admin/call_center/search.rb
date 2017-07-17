class Admin::CallCenter::Search < Admin::Base

  attr_accessor :term, :user

  # def authorized_user_types
  #   [:admin, :call_center]
  # end

  def pre_validate
    # super()
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.term = params[:query]
  end

  def process
    self.user = User.find_by(mobile_number: term) || User.find_by(email: term)
  end

  def success
    params[:user] = user
    Admin::CallCenter::Search::UserPresenter.new(user, params, messages)
  end

  class Admin::CallCenter::Search::UserPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :user

    def init
      self.user = params[:user]
    end
  end
end