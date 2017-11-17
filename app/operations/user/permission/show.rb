class User::Permission::Show < User::Permission::Base

  attr_accessor :permission, :permission_keys, :result_hash

  class User::Permission::Show::PermissionPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :permissions

    def init
      self.permissions = params[:permissions]
    end
  end

  def init
    id = params[:id] || params[:selected_user_id]
    self.selected_user = User::Index.(user, params).team.find_by(id: id) rescue nil
    self.permission = selected_user&.permission
  end

  def success
    params[:permissions] = self.permission
    User::Permission::Show::PermissionPresenter.new(user, params, messages)
  end
end