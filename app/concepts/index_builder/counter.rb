class IndexBuilder::Counter
  attr_accessor :filter_key

  module DSL
    extend ActiveSupport::Concern

    included do
      include DynamicAttributes

      class_attr :counter
    end
  end

  def initialize(filter_key)
    self.filter_key = filter_key
  end

  def counts
    @counts ||= []
  end

  def add(filter_id, label, count)
    count = {filter_id: filter_id, label: label.to_s.titleize, count: (count || 0)}
    counts << count
  end

  def as_json(options = {})
    {
        filter_key: filter_key,
        counts: counts
    }
  end

end