class Personalizer::Process < BaseOperation
  attr_accessor :params, :entity, :action

  def self.call(entity, action, params)
    self.new(entity, action, params).run
  end

  def initialize(entity, action, params)
    self.entity = entity
    self.action = action
    self.params = params
  end

  def process
    unless action.present?
      add_message :error, 'Action cannot be empty'
      return nil
    end
    company = current_company
    if company.blank?
      add_message :error, 'Company not found'
      return nil
    end
    company_id = company.id
    file_path = "#{Rails.root}/lib/personalizer/adapters/company#{company_id}/#{entity}#{company_id}/#{entity}_#{action}.rb"
    unless File.exists?(file_path)
      add_message :error, 'No personalization applied'
      return nil
    end
    Dir[file_path].each{|f| load f}
    class_name = "Personalizer::Adapters::Company#{company_id}::#{entity.to_s.camelize}#{company_id}::#{entity.to_s.camelize}#{action.to_s.camelize}"
    (Object.const_get(class_name).(self.entity, self.action, self.params) rescue nil)
  end

end