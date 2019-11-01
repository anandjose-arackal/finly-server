class Forms::Entity::Representers::Index  < Representable::Decorator
  include Representable::JSON

  property :form_id
  property :form_section, deserialize: -> (options) {
    debugger
  }

end