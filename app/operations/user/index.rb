class User::Index < User::Base
  attr_accessor :users

  def process
    operation = User::Team::Index.new(user, params)
    result = operation.run
    if operation.is_success?
      self.users = result
    else
      errors << operation.errors
    end
  end

  def success
    params[:team] = users
    User::Index::Presenter.new(user, params)
  end

  class User::Index::Presenter < BaseOperation::BasePresenter
    attr_accessor :team, :users_type_count, :users_status_count, :pending_invites_count

    has_scope :filter_search
    has_scope :filter_role
    has_scope :filter_status

    def initialize(user, params)
      super(user, params)
      if params[:team].present?
        self.team = apply_scopes(params[:team], params)
        self.users_type_count = self.team.joins(:role_mapping).group(:user_role_id).count
        self.users_status_count = self.team.group(:active).count
        self.pending_invites_count = self.team.pending.count
        self.team = self.team.paginate(page: params[:page], per_page: 30)
      end
    end
  end

end