class IndexSegment::Contracts::Update < Reform::Form

  property :screen, validates: {presence: true}
  property :name, validates: {presence: true}
  property :default
  property :filters # Todo create a standard filter validation to validate the filter format before persisting
  property :columns

end