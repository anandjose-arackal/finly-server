class CustomField::Configuration::DropDownItem::Remove < CustomField::Configuration::Base
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
    if params[:drop_down_item_id].blank?
      add_message :error, 'DropDown Item not found'
      return
    end
  end

  def init
    id = params[:field_configuration_id]
    self.field_configuration = CustomField::Configuration::Index.(user, params).field_configurations.with_id(id).first rescue nil
    if self.field_configuration.drop_down?
      drop_down_item_id = params[:drop_down_item_id]
      self.drop_down_item = self.field_configuration.drop_down_items.find_by_id(drop_down_item_id)
    end
  end

  def validate
    if field_configuration.blank?
      add_message :error, 'Field configuration not found'
      return
    end
    unless drop_down_item.present?
      add_message :error, 'DropDown Item not found'
      return
    end
  end

  def process
    self.drop_down_item.destroy

  end

end