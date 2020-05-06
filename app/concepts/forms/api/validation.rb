class Forms::API::Validation
  include DynamicAttributes
  include Forms::API::Rule::DSL

  instance_attr :entity_path
  instance_attr :error_message
  instance_attr :id
  instance_attr :internal, default: true
  instance_attr :can_be_updated, default: false

  def initialize(params={}, &block)
    params.each_pair do |key, value|
      self.send("#{key}=", value)
    end
    instance_eval &block if block_given?

    raise "No rules provided for the validation" if rules.blank?
    if self.id.blank?
      raise "Validation ID cannot be blank for #{self.entity_path}"
    end
  end

  # def sync(company, form_model)
  #   return if form_model.validations.find_by(validation_id: id, company_id: company.id).present?
  #
  #   # form_id
  #   form_entity = form_model.entities.find_by field_path: self.entity_path
  #   validation = form_model.validations.new(
  #       company_id: company.id,
  #       validation_id: id,
  #       form_entity_id: form_entity&.id,
  #       error_message: self.error_message,
  #       custom: false,
  #       internal: self.internal,
  #       is_updated: self.is_updated,
  #       can_be_updated: self.can_be_updated,
  #       rules_attributes: rules.map {|rule| rule.build(company, form_model)}
  #   )
  #   unless validation.valid?
  #     raise "Validation could not be saved due to #{validation.errors.full_messages}"
  #   end
  #   validation.save
  # end

end