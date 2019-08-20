class Personalizer::Adapters::Company2::Procurements2::Invoices2::Retract2::PostProcess < Personalizer::Adapters::Base

  attr_accessor :inward_invoice

  def init
    self.inward_invoice = op_instance.invoice
  end

  def process
    if inward_invoice.present? && inward_invoice.due_date.present?
      #check it passed
      trail_action_level_ids = []
      inward_invoice.trails.reorder(created_at:  :desc).each do |trail|
        break if trail.action_id == TrailAction.id_for(:submit)
        trail_action_level_ids << trail.action_level_id if trail.action_id == TrailAction.id_for(:approve)
      end
      if trail_action_level_ids.present? && ReviewalLevel.where(id: trail_action_level_ids).pluck(:level_number).include?(2)
        original_due_date = TransferTimingUtils.subtract_business_days(inward_invoice.due_date, 5)
        inward_invoice.update_columns(due_date: original_due_date)
      end
    end
  end

end