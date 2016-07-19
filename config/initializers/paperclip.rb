require 'paperclip/media_type_spoof_detector'
# todo as paperclip was throwing error "spoofed", had to include this workaround - https://github.com/thoughtbot/paperclip/issues/1470
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end