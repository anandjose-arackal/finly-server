# == Schema Information
#
# Table name: document_slice
#
#  id                  :integer          not null, primary key
#  page_number         :integer
#  image_file_name     :string(255)
#  image_content_type  :string(255)
#  image_file_size     :integer(4)
#  image_updated_at    :datetime
#  receipt_id          :integer(4)
#  created_at          :datetime
#  updated_at          :datetime
#

class DocumentSlice < ActiveRecord::Base
  belongs_to :receipt

  validates :image, presence: true

  has_attached_file :image, {
      styles: lambda {|a| a.instance.check_file_type}, #{normal: "1080x1080>"},
      default_url: '/assets/:style/missing.png'
  }
  validates_attachment :image, content_type: {
      # content_type: %w(image/jpg image/jpeg image/png image/gif )
      content_type: %w(image/jpg image/jpeg image/png image/gif)
  }

  def check_file_type
    if self.is_image?
      {
          normal: "1080x1080>"
      }
    end
  end

  def is_image?
    self.image_content_type =~ %r(image)
  end
end
