# Be sure to restart your server when you modify this file.

# Note: Liquid gem does not support lazy loading collection of records.
# Liquid::Utils.slice_collection will eagerly fetch records even
# if overwrite `each` and `load_slice` methods.
# So, we are overwriting Liquid::Utils.slice_collection method to
# check if `lazy_load_slice` method is available for the collection and use it.
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
