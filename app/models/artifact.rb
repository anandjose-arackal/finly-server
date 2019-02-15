class Artifact < ApplicationRecord
  include Attachable

  belongs_to :resource, polymorphic: true
  belongs_to :company

  CONTENT_TYPES = {content_type: []}
  has_attached_file :attachment, styles: lambda { |a| a.instance.check_file_type(a) }, default_url: '/assets/:style/missing.png'
  validates_attachment :attachment, content_type: CONTENT_TYPES

  scope :with_id, -> (ids) { where id: ids }
end
