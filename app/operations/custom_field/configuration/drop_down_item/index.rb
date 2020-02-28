class CustomField::Configuration::DropDownItem::Index < CustomField::Configuration::Base
  attr_accessor :field_configuration, :drop_down_items

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Configuration not loaded correctly'
      return
    end
    if params[:custom_field_id].blank?
      add_message :error, 'Custom Fieldnot found'
      return
    end
  end

  def init
    id = params[:custom_field_id]
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
  end

  def process
    self.drop_down_items = field_configuration.drop_down_items.exclude_deleted
  end

  def success
    params[:field_configuration] = self.field_configuration
    params[:drop_down_items] = self.drop_down_items
    CustomField::Configuration::DropDownItem::Index::SuccessPresenter.new(self.user, params)
  end

  class CustomField::Configuration::DropDownItem::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :field_configuration, :drop_down_items

    has_scope :filter_user_id
    has_scope :filter_user_email_mobile

    def init
      self.field_configuration = params[:field_configuration]
      self.drop_down_items = params[:drop_down_items]
      self.drop_down_items = apply_scopes(self.drop_down_items, params)
    end

  end

end