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

  # Define first, second, third, etc. methods
  offset_methods = []
    first: 1,
    second: 2,
    third: 3,
    fourth: 4,
    fifth: 5,
    sixth: 6,
    seventh: 7,
    eighth: 8,
    ninth: 9,
    tenth: 10,
  }

  offsets.each do |name, offset|
    define_method name do
      relation.offset(offset-1).first&.to_exposure
    end
  end

  def last
    relation.last&.to_exposure
  end

  def second_to_last
    relation.second_to_last&.to_exposure
  end

  def third_to_last
    relation.third_to_last&.to_exposure
  end

  def each
    relation.find_in_batches(batch_size: batch_size) do |records|
      records.each do |record|
        yield record.to_exposure
      end
    end
  end
end
