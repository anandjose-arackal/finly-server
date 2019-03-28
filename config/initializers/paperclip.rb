require 'paperclip/media_type_spoof_detector'
# https://github.com/thoughtbot/paperclip/issues/2575
Paperclip::DataUriAdapter.register

# todo as paperclip was throwing error "spoofed", had to include this workaround - https://github.com/thoughtbot/paperclip/issues/1470
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
  # module ClassMethods
  #   def has_attached_file(name, options = {})
  #     # As s3 pdf's don't open up correctly if content_disposition is set as attachment for PDFs
  #     options.merge!({:s3_headers => lambda {|a| (a.send("#{name}_content_type") =~ %r{\.(pdf)$}i || a.send("#{name}_content_type") =~ %r(image)) ? '' : {:content_disposition => 'attachment'}}})
  #     HasAttachedFile.define_on(self, name, options)
  #   end
  # end


  module Storage
    module S3
      # As s3 pdf's don't open up correctly if content_disposition is set as attachment for PDFs. Monkey patching paperclip
      def flush_writes #:nodoc:
        @queued_for_write.each do |style, file|
          retries = 0
          begin
            log("saving #{path(style)}")

            # remove content disposition of attachment if the current style is not original
            amended_s3_headers = @s3_headers.dup
            puts "before: #{amended_s3_headers}"
            amended_s3_headers.delete(:content_disposition) if (file.content_type == 'application/pdf')
            puts "after: #{amended_s3_headers}"

            puts "content: #{file.content_type}"
            puts "content-disposition: #{(file.content_type == 'application/pdf')}"

            write_options = {
                :content_type => file.content_type,
                :acl => s3_permissions(style)
            }

            # add storage class for this style if defined
            storage_class = s3_storage_class(style)
            write_options.merge!(:storage_class => storage_class) if storage_class

            if @s3_server_side_encryption
              write_options[:server_side_encryption] = @s3_server_side_encryption
            end

            style_specific_options = styles[style]

            if style_specific_options
              merge_s3_headers( style_specific_options[:s3_headers], @s3_headers, @s3_metadata) if style_specific_options[:s3_headers]
              @s3_metadata.merge!(style_specific_options[:s3_metadata]) if style_specific_options[:s3_metadata]
            end

            write_options[:metadata] = @s3_metadata unless @s3_metadata.empty?
            write_options.merge!(amended_s3_headers)

            s3_object(style).upload_file(file.path, write_options)
          rescue ::Aws::S3::Errors::NoSuchBucket
            create_bucket
            retry
          rescue ::Aws::S3::Errors::SlowDown
            retries += 1
            if retries <= 5
              sleep((2 ** retries) * 0.5)
              retry
            else
              raise
            end
          ensure
            file.rewind
          end
        end

        after_flush_writes # allows attachment to clean up temp files

        @queued_for_write = {}
      end
    end
  end
end