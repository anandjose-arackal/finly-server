class AutoComplete::API < Transactions::API
  include DynamicAttributes
  extend Dry::Container::Mixin

  class_attr :model
  class_attr :resolver
  class_attr :render
  class_attr :render_record

  step Transactions::Resolver::Load(builder: :resolver_builder)

  def self.resolver(context, options)
    self.class.resolver || self.class.model&.resolver
  end

  def self.handle(handle = NoObject)
    if handle.present?
      @handle = handle
      AutoComplete::API.register(handle, self)
    end
    @handle
  end

end