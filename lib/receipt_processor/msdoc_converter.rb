require_relative 'html_converter'
module ReceiptProcessor
  # encapsulates functionality for Microsoft document to image conversion
  class MSDocConverter
    def convert(doc, image_tmp_path)
      images = []
      Proselytism.convert doc, to: :html do |html_path|
        html_string = File.read html_path
        images = ReceiptProcessor::HTMLConverter.new.convert html_string, image_tmp_path
      end
      images
    end
  end
end
