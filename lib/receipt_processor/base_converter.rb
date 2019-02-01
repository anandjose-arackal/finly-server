require_relative 'pdf_converter'
require_relative 'msdoc_converter'
require_relative 'html_converter'
require_relative 'image_converter'

# encapsulates complete receipt processing functionality
module ReceiptProcessor
  # encapsulates functionality to convert different content types to images
  class BaseConverter
    PDF_CONTENT_TYPES ||= ['application/pdf'].freeze
    IMAGE_CONTENT_TYPES ||= ['image/jpg', 'image/jpeg', 'image/png', 'image/gif'].freeze
    HTML_CONTENT_TYPES ||= ['text/html'].freeze
    MSWORD_CONTENT_TYPES ||= ['application/rtf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'].freeze

    def initialize(doc, doc_content_type, image_tmp_path)
      @content_type = doc_content_type
      @doc = doc
      @image_tmp_path = image_tmp_path
      if pdf?
        @converter = PDFConverter.new
      elsif html?
        @converter = HTMLConverter.new
        # Removing support for MSDoc and Image as receipt
        # elsif msdoc?
        #   @converter = MSDocConverter.new
        # elsif image?
        #   @converter = ImageConverter.new
      else
        # raise "#{doc_content_type} content type not supported"
      end
    end

    def convert
      images = @converter.convert @doc, @image_tmp_path
      if block_given?
        yield images
        images.each do |image|
          File.delete image
        end
      else
        images
      end
    end

    def pdf?
      PDF_CONTENT_TYPES.include? @content_type
    end

    def image?
      IMAGE_CONTENT_TYPES.include? @content_type
    end

    def msdoc?
      MSWORD_CONTENT_TYPES.include? @content_type
    end

    def html?
      HTML_CONTENT_TYPES.include? @content_type
    end

    def self.is_receipt?(content_type)
      PDF_CONTENT_TYPES.include?(content_type) || IMAGE_CONTENT_TYPES.include?(content_type)
    end

  end

end
