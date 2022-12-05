class ImportJobAttachment < ApplicationRecord
  include UUIDHelper
  include Exposures::Model::Exposable

  belongs_to :import_job
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :company

  has_attached_file :attachment, :use_timestamp => false
  validates_attachment :attachment, content_type: {content_type: []}

  def as_json(options={})
    if options[:compact]
      {
        id: uuid,
        identifier: identifier,
        url: attachment&.url,
        filename: self.attachment_file_name,
      }
    else
      att_data = super
      att_data['url'] = attachment&.url
      att_data['filename'] = self.attachment_file_name
      att_data
    end
  end

end
