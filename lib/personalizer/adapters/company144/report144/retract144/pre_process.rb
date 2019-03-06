class Personalizer::Adapters::Company144::Report144::Retract144::PreProcess < Personalizer::Adapters::Base
  attr_accessor :op_instance, :report

  # Ensure that if it is approved by all managers, the report cannot be retracted

  def validate
    if approvers_actioned?
     add_message :error, 'The report cannot be retracted at the moment'
    end
  end

  def approvers_actioned?
    self.report = op_instance.report
    if report.present?
      if report.document_level_reviewer_mappings.present?
        return true if report.document_level_reviewer_mappings.where(action_id: TrailAction.id_for(:approve)).present?
      end
    end
    false
  end

end
