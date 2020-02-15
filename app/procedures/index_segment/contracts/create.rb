class IndexSegment::Contracts::Create < IndexSegment::Contracts::Update

   property :company, validates: {presence: true}
   property :user, validates: {presence: true}

end