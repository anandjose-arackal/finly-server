class User::Index < User::Base
  attr_accessor :users

  def process
    operation = User::Team::Index.new(user, params)
    result = operation.run
    if operation.success?
      self.users = result
    else
      add_message :error, (operation.messages[:error] + operation.messages[:failure])
    end
  end

  def success
    params[:team] = users
    User::Index::Presenter.new(user, params, messages)
  end

  class User::Index::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :team, :users_type_count, :users_status_count, :pending_invites_count, :paginated_team, :count

    def init
      if params[:team].present?
        self.team = params[:team]
        self.count = self.team.count
        per_page = params[:per_page] || 30
        self.paginated_team = self.team.paginate(page: params[:page], per_page: per_page)
      end
    end
  end

end
