class Forms::API::Entity::Types::Switch < Forms::API::Entity::Base
  register :switch

  operators operators :eq_any, :blank, :present

  def initialize(section, field_key, parent_path, opts = {}, &block)
    super(section, field_key, parent_path, opts.merge(choices_scope: Choices[:switch].()), &block)
  end

end