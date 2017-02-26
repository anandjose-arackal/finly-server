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
    attr_accessor :team, :users_type_count, :users_status_count, :pending_invites_count, :paginated_team

    has_scope :filter_search
    has_scope :filter_role
    has_scope :filter_state

    def init
      if params[:team].present?
        self.team = apply_scopes(params[:team], params)
        # todo - need to debug below statements. Disabling for now, as we're not using it anywhere
        # self.users_type_count = self.team.joins(:role_mapping).group(:user_role_id).count
        # self.users_status_count = self.team.all.group(:active).count
        # self.pending_invites_count = self.team.pending.count
        self.paginated_team = self.team.paginate(page: params[:page], per_page: 30)
      end
    end
  end

end
