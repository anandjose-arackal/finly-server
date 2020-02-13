class Filters::API::Attribute

  attr_accessor :field_key, :label, :field_type, :scope, :hint

  # Includes: Used for capturing the data points to be included to optimize the fetch for the current record
  def initialize(field_key:, label:, hint:, field_type:, scope: nil)
    self.field_key = field_key
    self.label = label
    self.hint = hint
    self.field_type = field_type
    self.scope = scope
  end

  def operators
    Forms::API::Entity::Registry.types[field_type].operators
  end

  def build
    params = {
        field_key: field_key,
        label: label,
        hint: hint,
        field_type: field_type,
        operators: operators
    }
    params[:scope] = scope if scope
    params
  end

end