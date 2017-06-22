module Attachable
  extend ActiveSupport::Concern

  def is_image?(content_type)
    content_type =~ %r(image)
  end

  def is_pdf?(content_type)
    content_type =~ %r{\.(pdf)$}i
  end

  def check_file_type(file)
    if file.present? and is_image? file.content_type
      {
          :thumb => '500x500>',
          large: '2160x2160>',
          normal: '1080x1080>'
      }
    else
      {

      }
    end
  end

  def file_format(file)
    return nil if file.blank?
    if file.image_content_type == 'application/pdf'
      'pdf'
    elsif ['image/jpg', 'image/jpeg', 'image/png', 'image/gif'].include?(self.image_content_type)
      'image'
    else
      'image'
    end
  end

end