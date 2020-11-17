class AuditTrail < PaperTrail::Version
  include Exposures::Model::Exposable
  include Resolver::ActiveRecordHelper
  include Ransacker
  self.abstract_class = true
  include SoftDeletable

  belongs_to :created_by, optional: true, class_name: "User"
end