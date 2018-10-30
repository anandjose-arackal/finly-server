class User::Permission::CheckPermissions < User::Permission::Base

  attr_accessor :permission, :permission_keys, :result_hash

  class User::Permission::CheckPermissions::PermissionPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :permissions

    def init
      self.permissions = params[:permissions]
    end
  end

  def init
    super
    self.permission_keys = params[:permissible_actions]
    self.result_hash = {}
  end

  def validate
    non_existent_keys = self.permission_keys - UserPermission.column_names
    self.permission_keys = self.permission_keys - non_existent_keys
  end

  def process
    self.permission_keys.each do |key|
      self.result_hash[key] = self.permission.send(key)
    end

  end

  def success
    params[:permissions] = self.result_hash
    params[:selected_user] = self.selected_user
    User::Permission::CheckPermissions::PermissionPresenter.new(user, params, messages)
  end

end