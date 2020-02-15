class IndexSegment::Contracts::Create < Reform::Form

   property :screen, validates: {presence: true}
   property :name, validates: {presence: true}
   property :filters # Todo create a standard filter validation to validate the filter format before persisting
   property :columns
   property :company, validates: {presence: true}
   property :user, validates: {presence: true}

end