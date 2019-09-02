class Forms::Definitions::Dependency
  attr_accessor :controlling_field, :dependent_field, :populate, :choices, :fields, :required_fields

  def initialize(controlling_field, dependent_field, populate: nil, choices: nil, fields: nil, required_fields: nil)
    self.controlling_field = controlling_field
    self.dependent_field = dependent_field
    self.populate = populate
    self.choices = choices
    self.fields = fields
    self.required_fields = required_fields
  end

end