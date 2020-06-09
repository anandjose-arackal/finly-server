class Forms::Contracts::Base < Reform::Form

  def bulk_validate_choice(entity, value)
    entity_choice_validations = choice_validations(entity)
    entity_choice_validations << value unless entity_choice_validations.include?(value)
  end

  def queue_computation(represented, entity)
    computation_queue.add(represented, entity)
  end

  def choice_validations(entity = nil)
    @choice_validations ||= {}
    if entity.present?
      @choice_validations[entity] ||= []
      return @choice_validations[entity]
    end
    @choice_validations
  end

  def computation_queue
    @computation_queue ||= Forms::Contracts::Helpers::ComputationQueue.new
  end

  validate :run_computations
  validate :run_choice_validations

  def current_user
    nil
  end

  def run_choice_validations
    self.choice_validations.each_pair do |entity, values|
      result = Forms::Ops::Choices.(
          params: {
              entity_path: entity.entity_path,
              form_record: entity.form,
              qs: {id_in: values} # Pass the ID as a simple filter
          }, current_user: current_user
      )
      # Fixme: This is working only for lookup
      if result[:choices].data.size != values.size
        errors.add entity.entity_key, 'has an invalid choice'
      end
    end
  end

  def run_computations
    computation_queue.execute(self)
  end

end