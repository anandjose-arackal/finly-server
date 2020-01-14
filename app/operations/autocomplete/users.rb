class Autocomplete::Users < BaseOperation

  attr_accessor :users

  def init
    params[:filter_search] = params[:filter_search].strip if params[:filter_search].present?
  end

  def process
    params[:filter_approved] = true
    params[:non_deleted] = true
    params[:filter_active] = true
    op = ::Users::Index.(user, params)
    if op.success?
      self.users = op.users
    end
  end

  def success
    params[:users] = self.users
    Autocomplete::Users::UsersPresenter.new(user, params, messages)
  end

  class Autocomplete::Users::UsersPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :users, :paginated_users

    def init
      self.users = params[:users]

      page = params[:page] || 1
      per_page = 10
      self.paginated_users = self.users.paginate(page: page, per_page: per_page)
    end
  end
end