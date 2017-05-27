class UserGroup::Item::Update < UserGroup::Item::Users::Base
  attr_accessor :item, :group, :name

  def pre_validate
    super
    return if has_errors?
    if params&.dig(:name).blank?
      add_message :error, 'Name cannot be blank'
      return
    end
  end

  def init
    item_presenter = UserGroup::Item::Show.(user, params)
    if item_presenter.failure?
      add_message :error, item_presenter.messages[:error]
      return
    end
    self.item = item_presenter.item
    self.group = item_presenter.group
    self.name = params[:name]
  end

  def process
    unless self.item.update(name: self.name)
      add_message :error, self.item.errors.full_messages
      return
    end
  end

end