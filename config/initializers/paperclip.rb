require 'paperclip/media_type_spoof_detector'
# todo as paperclip was throwing error "spoofed", had to include this workaround - https://github.com/thoughtbot/paperclip/issues/1470
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
  module ClassMethods
    def has_attached_file(name, options = {})
      # As s3 pdf's don't open up correctly if content_disposition is set as attachment for PDFs
      unless lambda {|a| a.instance.content_type =~ %r{\.(pdf)$}i || a.instance.content_type =~ %r(image)}
        options.merge({s3_headers: {content_disposition: 'attachment'}})
      end
      HasAttachedFile.define_on(self, name, options)
    end
  end
end