class CustomField::Configuration::DropDownItem::Add < CustomField::Configuration::Base
  attr_accessor :field_configuration, :drop_down_items, :items, :drop_down_items

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
    if params[:items].blank?
      add_message :error, 'Nothing to add'
      return
    end
  end

  def init
    id = params[:field_configuration_id]
    self.field_configuration = CustomField::Configuration::Index.(user, params).field_configurations.with_id(id).first rescue nil
    self.items = params[:items]
    self.items = self.items&.reject { |item| item[:name].blank? }
    if items.blank?
      add_message :error, 'Nothing to add'
      return
    end
    self.drop_down_items = []
    self.items.each do |item|
      self.drop_down_items << self.field_configuration.drop_down_items.build(name: item[:name])
    end
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
    if self.drop_down_items.blank?
      add_message :error, 'Nothing to add'
      return
    end
    self.drop_down_items.each do |item|
      unless item.valid?
        add_message :error, item.errors.full_messages
        return
      end
    end
  end

  def process
    self.drop_down_items.each do |item|
      item.save
    end
  end

end