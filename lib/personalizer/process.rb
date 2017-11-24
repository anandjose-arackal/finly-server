class Personalizer::Process < BaseOperation
  attr_accessor :params, :path, :function, :company, :class_object, :show_errors, :op_instance

  # Show errors is used to show failure only if a personalization exists and the personalization is throwing an error. Else success presenter is returned

  def self.call(path, function, instance)
    self.new(path, function, instance).run
  end

  def initialize(path, function, instance)
    self.path = path
    self.function = function
    self.op_instance = instance
    self.params = instance.params if instance&.respond_to? :params
    self.user = instance.user if instance&.respond_to? :user
  end

  def pre_validate
    unless path.present? or function.blank?
      add_message :error, 'Path cannot be empty'
      return nil
    end
  end

  def init
    self.show_errors = false
    company = current_company
    if company.blank?
      add_message :error, 'Company not found'
      return nil
    end
    company_id = company.id

    # Generate the path to the file to check if file exists
    self.path = [self.path] unless self.path.is_a?(Array)
    dir_path = ''
    self.path.each do |s|
      if dir_path.length > 0
        dir_path += '/'
      end
      dir_path += "#{s}#{company_id}"
    end
    file_path = "#{Rails.root}/lib/personalizer/adapters/company#{company_id}/#{dir_path}/#{function}.rb"
    unless File.exists?(file_path)
      add_message :error, 'No personalization applied'
      return nil
    end
    # Load the required personalizer file
    Dir[file_path].each{|f| load f}

    # Generate class name
    class_name = "Personalizer::Adapters::Company#{company_id}"
    self.path.each do |s|
      class_name += "::#{s.to_s.camelize}#{company_id}"
    end
    class_name += "::#{function.to_s.camelize}"

    # Execute class
    self.class_object = (Object.const_get(class_name).new(self.op_instance, self.user, self.params) rescue nil)
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
      self.show_errors = true
      add_message :error, self.class_object.messages[:error]
      return
    end
  end

  # This is overridden to show failure only if a personalization exists and the personalization is throwing an error
  def failure
    if self.show_errors
      super
    else
      clear_messages
      success
    end
  end

end