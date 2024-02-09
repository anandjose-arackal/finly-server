class UserGroup::Destroy < UserGroup::Base

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def process
    self.user_group.user_group_items.each do |item|
      item.destroy
    end
    unless self.user_group.destroy
      add_message :error, self.user_group.errors.full_messages
      return
    end
  end

end