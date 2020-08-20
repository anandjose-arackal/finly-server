# Note: Liquid gem does not support lazy loading Array of records.
# Liquid::Utils.slice_collection will eagerly fetch records even if overwrite `each` and `load_slice` methods.
# So, we are overwriting Liquid::Utils.slice_collection method to check if `lazy_load_slice` method is available for the collection and use it.
# Original code available at https://github.com/Shopify/liquid/blob/master/lib/liquid/utils.rb
module Liquid
  module Utils
    def self.slice_collection(collection, from, to)
      if collection.respond_to?(:lazy_load_slice)
        collection.lazy_load_slice(from, to)
      elsif (from != 0 || !to.nil?) && collection.respond_to?(:load_slice)
        collection.load_slice(from, to)
      else
        slice_collection_using_each(collection, from, to)
      end
    end
  end
end


# Use Exposures::LazyList to create Exposure List for list of active records
# Example Usage: Exposure::LazyList.(Invoice.all)
class Exposures::LazyList < Exposures::API
  attr_accessor :relation, :batch_size

  def initialize(relation, batch_size: 100)
    self.relation = relation
    self.batch_size = batch_size
  end

  def self.call(relation)
    new(relation)
  end

  def length
    relation.count
  end

  def empty?
    relation.empty?
  end

  def reversed!
    # TODO: update this method to reverse order of records
    self
  end

  def lazy_load_slice(from, to)
    # TODO: update this method to filter records
    self
  end

  def each
    relation.find_in_batches(batch_size: batch_size) do |records|
      records.each do |record|
        yield record.to_exposure
      end
    end
  end
end
