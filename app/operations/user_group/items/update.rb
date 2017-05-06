class UserGroup::Items::Update < UserGroup::Items::Base

  def pre_validate
    super
    return if has_errors?
    unless params&.dig(:name).present?
      add_message :error, 'Name cannot be blank'
    end
  end

  def process
    unless self.user_group_item.update(name: params[:name])
      add_message :error, self.user_group_item.errors.full_messages
    end
  end

end