module IndexBuilder::ContentTypes::Registry
  extend ActiveSupport::Concern

  def self.types
    @types ||= {}.with_indifferent_access
  end

  def self.register(type, klass)
    IndexBuilder::ContentTypes::Registry.types[type] = klass

    IndexBuilder::ContentTypes::Registry.module_eval do
      define_method type do |*args|
        opts = args.extract_options!
        # @position ||= 0
        field type, opts#.merge(position: @position)
        # @position += 1
      end
    end
  end

end