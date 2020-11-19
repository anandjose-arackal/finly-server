class AuditTrail < PaperTrail::Version
  include Exposures::Model::Exposable
  include Resolver::ActiveRecordHelper
  include Ransacker
  self.abstract_class = true
  include SoftDeletable

  default_scope {order(created_at: :desc)}

  belongs_to :created_by, optional: true, class_name: "User"

  def changes_less
    self.changeset&.first(2).map{|change| "#{change&.first&.titlecase} Changed #{(change&.last)&.join(' -> ')}"}&.join(' , ')
  end

end