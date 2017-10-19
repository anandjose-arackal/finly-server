class CustomField::Configuration::DropDownItem::Add < CustomField::Configuration::Base
  attr_accessor :field_configuration, :drop_down_item

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
    if params[:name].blank?
      add_message :error, 'DropDown label cannot be empty'
      return
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
      add_message :error, 'DropDown Item can only be added to DropDown Custom Fields'
      return
    end
  end

  def process
    self.drop_down_item = self.field_configuration.drop_down_items.build name: params[:name]
    unless self.drop_down_item.valid?
      add_message :error, self.drop_down_item.errors.full_messages
      return
    end
    unless self.drop_down_item.save
      add_message :error, self.drop_down_item.errors.full_messages
      return
    end
  end

end