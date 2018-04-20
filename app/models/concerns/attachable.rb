module Attachable
  extend ActiveSupport::Concern

  # Old code
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
    elsif is_pdf?(file.content_type)
      {
          :thumb => ["500x500>", :png],
          :normal => ["1080x1080>", :png],
          :large => ["2160x2160>", :png]
      }
    else
      {}
    end
  end
  # Old code ends

  # New Code
  def format_pdf?(paperclip_object)
    paperclip_object.content_type == 'application/pdf'
  end

  def format_image?(paperclip_object)
    ['image/jpg', 'image/jpeg', 'image/png', 'image/gif'].include?(paperclip_object.content_type)
  end

  def style_format(paperclip_object)
    if paperclip_object.present? && format_pdf?(paperclip_object)
      {
          :thumb => ['500x500>', :png],
          large: '2160x2160>',
          normal: '1080x1080>'
      }
    elsif paperclip_object.present? && format_image?(paperclip_object)
      {
          :thumb => '500x500>',
          large: '2160x2160>',
          normal: '1080x1080>'
      }
    else
      {}
    end
  end

  # New Code ends



  def file_format(file)
    return nil if file.blank?
    if file.content_type == 'application/pdf'
      'pdf'
    elsif ['image/jpg', 'image/jpeg', 'image/png', 'image/gif'].include?(file.content_type)
      'image'
    else
      'image'
    end
  end

end