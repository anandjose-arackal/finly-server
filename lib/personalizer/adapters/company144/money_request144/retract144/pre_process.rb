class Personalizer::Adapters::Company144::MoneyRequest144::Retract144::PreProcess < Personalizer::Adapters::Base
  attr_accessor :op_instance, :money_request


  # Ensure that if it is approved by all managers, the report cannot be retracted
  def validate
    if approvers_actioned?
      add_message :error, 'The request cannot be retracted at the moment'
    end
  end

  def approvers_actioned?
    self.money_request = op_instance.money_request
    if money_request.present?
      if money_request.document_level_reviewer_mappings.present?
        return true if money_request.document_level_reviewer_mappings.where(action_id: TrailAction.id_for(:approve)).present?
      end
    end
    false
  end

end
