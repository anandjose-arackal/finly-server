# Use Exposures::LazyList to create Exposure List for list of active records
# Example Usage: Exposure::LazyList.(Invoice.all)
#                Invoice.all.to_exposures
class Exposures::LazyList < Exposures::API
  attr_accessor :relation, :batch_size

  def initialize(relation, batch_size: 100)
    self.relation = relation.all
    self.batch_size = batch_size
  end

  def self.call(relation)
    new(relation)
  end

  def count
    relation.count
  end

  alias_method :length, :count

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
