class CustomField::Configuration::DropDownItem::Index < CustomField::Configuration::Base
  attr_accessor :field_configuration, :drop_down_items, :drop_down_user

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Configuration not loaded correctly'
      return
    end
    if params[:field_configuration_id].blank?
      add_message :error, 'Field configuration not found'
      return
    end
    if params[:user_id].blank?
      add_message :error, 'Dropdown user not found'
    end
  end

  def init
    id = params[:field_configuration_id]
    self.field_configuration = CustomField::Configuration::Index.(user, params).field_configurations.with_id(id).first rescue nil
  end

  def validate
    if field_configuration.blank?
      add_message :error, 'Field configuration not found'
      return
    end
    unless field_configuration.drop_down?
      add_message :error, 'Not a Drop Down Item'
      return
    end

    self.drop_down_user = user.company.users.find_by id: params[:id]
    if drop_down_user.blank?
      add_message :error, 'Dropdown user not found'
      return
    end
  end

  def process
    self.drop_down_items = field_configuration.drop_down_items.exclude_deleted.items_for_user(params[:user_id]&.to_i)
  end

  def success
    params[:field_configuration] = self.field_configuration
    params[:drop_down_items] = self.drop_down_items
    params[:drop_down_user] = self.drop_down_user
    CustomField::Configuration::DropDownItem::Index::SuccessPresenter.new(self.user, params)
  end

  class CustomField::Configuration::DropDownItem::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :field_configuration, :drop_down_items, :drop_down_user

    def init
      self.field_configuration = params[:field_configuration]
      self.drop_down_items = params[:drop_down_items]
      self.drop_down_user = params[:drop_down_user]
    end

  end

end