class Forms::Entity::Types::Boolean < Forms::Entity::Base
  register :boolean

  def initialize(section, field_key, parent_path, opts = {}, &block)
    super(section, field_key, parent_path, opts.merge(scope: Forms::Entity::Scope::Boolean()), &block)
  end
end