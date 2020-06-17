class Forms::API::Entity::Types::CheckBox < Forms::API::Entity::Base
  register :checkbox

  operators :true, :false

  def initialize(section, field_key, parent_path, opts = {}, &block)
    super(section, field_key, parent_path, opts.merge(choices_provider: Choices[:checkbox].()), &block)
  end

  # hint 'Select option'
  # multiple true
  #
  # consumes_choices!
  #
  # option :min_choices
  # option :max_choices
  #
  # contract do
  #   optional(:min_choices).value(:int?)
  #   optional(:max_choices).value(:int?)
  # end
end