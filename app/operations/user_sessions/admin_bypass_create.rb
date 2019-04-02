require 'resolv'
class UserSessions::AdminBypassCreate < UserSessions::Create
  attr_accessor :admin_user

  def initialize(status, params)
    super(status, params)
    self.admin_user = params[:admin_user]
  end

  def process
    args = {}
    args[:status_id] = UserSessionStatus.id_for(self.status)
    args[:message] = params[:message]
    enrich_user args
    enrich_device args
    enrich_admin_user args
    enrich_request args
    enrich_access args
    set_event args
    return if has_errors?
    self.session = UserSession.new args
    unless self.session.valid?
      add_message :error, session.errors.full_messages
      return
    end
    self.session.save
  end

  def post_process
    super

    RequestStoreUtil.set_current_admin_user self.admin_user
    self.token&.update(admin_user_id: self.admin_user.id)
  end

  def enrich_admin_user(args)
    return unless user.present?

    self.admin_user = AdminUser.find_for_database_authentication(:username => params[:username])
    unless admin_user
      if self.status == :authorized
        args[:status_id] = UserSessionStatus.id_for(:failed)
        args[:message] = 'Admin user not found'
      end
      return
    end

    args[:admin_user_id] = admin_user.id
  end

  def enrich_device(args)
    args[:client_type] = params[:temporary_client_type]
  end

end
