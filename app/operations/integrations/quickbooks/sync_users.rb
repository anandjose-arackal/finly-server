# as of now, not required, will only sync employees that are in both
# so vendors, and other types will be integrated later if required

class Integrations::Quickbooks::SyncUsers < Integrations::Quickbooks::Base

  def process
    users = adapter.users
    users.each do |user|
      if user.quickbooks_user_type == "Employee"
        user.save
      end
    end
  end

  def post_process
    add_message :success, "Users synced!"
  end
end
