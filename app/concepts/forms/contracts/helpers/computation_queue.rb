# Responsible for queuing all computations at deserialization stage and run the computation post deserialization
class Forms::Contracts::Helpers::ComputationQueue

  def queue(entity = nil)
    @queue ||= {}
    if entity.present?
      @queue[entity] ||= []
      return @queue[entity]
    end
    @queue
  end

  def add(represented, entity)
    queue(entity) << represented
  end

  def execute(contract)
    # This takes an assumption that the hash(computation queue) maintained by ruby is an ordered hash. Reference: https://www.igvita.com/2009/02/04/ruby-19-internals-ordered-hash/
    # This logic will break if the hash is un-ordered or the insertion order is tampered.
    # Improvement: computation_priority can be defined as a variable, we can move to that as well as that enables the end user to be able to define the computation order
    queue.each_pair do |entity, represented_list|
      case entity.compute_type_id
      when FormEntityComputationType.id_for(:lookup)
        LookupRunner.(contract, entity, represented_list)
      when FormEntityComputationType.id_for(:form)
        FormRunner.(contract, entity, represented_list)
      else
        # Do nothing
      end
    end
  end

  class LookupRunner
    def self.call(contract, entity, represented_list)
      user = nil
      lookup_values = {}
      represented_list.each do |represented|
        form = represented.contract_root.to_form
        row = represented.to_form
        lookup_value = Forms::RequestParser.new(form: form, row: row).fetch(entity.compute_lookup_entity.entity_path)
        return unless lookup_value.present?

        lookup_values[represented] = lookup_value
      end

      # Use the document owner or the current user for fetching the lookup choices
      user ||= contract.respond_to?(:created_by) ? contract.created_by : RequestStoreUtil.current_user
      return unless user.present?

      lookup_records = entity.compute_lookup_entity.choices_scope.with_id(lookup_values.values, params: {}, user: user)
      lookup_exposures = {}
      lookup_records.each {|record| lookup_exposures[record.id.to_s] = record.to_exposure }

      represented_list.each do |represented|
        lookup_value = lookup_values[represented]
        return if lookup_value.blank?

        lookup_exposure = lookup_exposures[lookup_value.to_s]
        return if lookup_exposure.nil?

        value = lookup_exposure.template(entity.compute_formula)
        entity.populate(represented, value)
      end
    end
  end

  class FormRunner
    def self.call(contract, entity, represented_list)
      transformer = Liquid::Template.parse(entity.compute_formula)
      represented_list.each do |represented|
        form = contract.to_form
        row = represented.to_form
        value = transformer.render({row: row, form: form}.as_json)
        entity.populate(represented, value)
      end
    end
  end

end