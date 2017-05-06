class UserGroup::Update < UserGroup::Base
  attr_accessor :name

  def pre_validate
    super
    return if has_errors?
    unless params&.dig(:name)
      add_message :error, 'Name cannot be empty'
    end
  end

  def process
    unless user_group.update(name: params[:name])
      add_message :error, user_group.errors.full_messages
    end
  end

end