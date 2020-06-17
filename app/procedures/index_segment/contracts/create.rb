class IndexSegment::Contracts::Create < IndexSegment::Contracts::Update

  property :company, validates: {presence: true}
  property :user, validates: {presence: true}
  property :application, deserializer: -> (input, represented, **) {represented.application = RequestStoreUtil.current_app}

end