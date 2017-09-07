class Personalizer::Process < BaseOperation
  attr_accessor :params, :entity, :action, :function, :company, :class_object

  def self.call(entity, action, function, params)
    self.new(entity, action, function, params).run
  end

  def initialize(entity, action, function, params)
    self.entity = entity
    self.action = action
    self.params = params
    self.function = function
  end

  def pre_validate
    unless action.present?
      add_message :error, 'Action cannot be empty'
      return nil
    end
    unless function.present?
      add_message :error, 'Function cannot be empty'
      return nil
    end
  end

  def init
    company = current_company
    if company.blank?
      add_message :error, 'Company not found'
      return nil
    end
    company_id = company.id
    file_path = "#{Rails.root}/lib/personalizer/adapters/company#{company_id}/#{entity}#{company_id}/#{action}#{company_id}/#{function}.rb"
    unless File.exists?(file_path)
      add_message :message, 'No personalization applied'
      return nil
    end
    Dir[file_path].each{|f| load f}
    class_name = "Personalizer::Adapters::Company#{company_id}::#{entity.to_s.camelize}#{company_id}::#{action.to_s.camelize}#{company_id}::#{function.to_s.camelize}"
    self.class_object = (Object.const_get(class_name).new(self.entity, self.action, self.params) rescue nil)
  end

  def validate
    unless self.class_object.present?
      add_message :error, 'Personalizer: Failed to initialize configuration'
      return
    end
    if self.class_object.has_errors?
      add_message :error, self.class_object.messages[:error]
      return
    end
  end

  def process
    self.class_object.run
    if self.class_object.has_errors?
      add_message :error, self.class_object.messages[:error]
      return
    end
  end

end