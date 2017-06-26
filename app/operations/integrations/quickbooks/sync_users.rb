# as of now, not required, will be explored properly further if necessary

class SyncUsers < Integrations::Base

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