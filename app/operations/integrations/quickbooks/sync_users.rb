class SyncUsers < Integrations::Base

  def pre_validate
    if company.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def process
    users = adapter.users
    users.each do |user|
      user.save
    end
  end

  def post_process
    add_message :success, "Users synced"
  end
end