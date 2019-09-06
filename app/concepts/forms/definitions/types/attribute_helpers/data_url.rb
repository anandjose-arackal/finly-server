module Forms::Definitions::Types::AttributeHelpers::DataUrl

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def consumes_data_url!
      @consumes_data_url = true
    end

    def consumes_data_url?
      !!@consumes_data_url
    end

  end

  def self.load_attributes(klass)
    return unless klass.class.consumes_data_url?
    return if klass.attributes.nil?
    # Nothing to do
  end

  def data_url
    # todo convert model and filters to a URL
  end

end
