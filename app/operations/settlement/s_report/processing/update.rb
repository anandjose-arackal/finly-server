# Update UTR and Paid status individually for the iten from the Batch show page
# 
class Settlement::SReport::Processing::Update < Settlement::SReport::Processing::Base
  attr_accessor :report_processor_group, :pending_mapping

  def authorized_user_types
    [:admin, :finance_manager]
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless params.dig(:batch_id).present?
      add_message :error, 'Batch not found'
      return
    end
    unless params[:id].blank?
      add_message :error, "Request details not sent"
      return
    end
  end

  def init
    groups_presenter = Settlement::SReport::Processing::Index.(user, params)
    unless groups_presenter.success?
      add_message :error, groups_presenter.messages[:error]
      return
    end
    self.report_processor_group = groups_presenter.report_processor_groups.find_by_id(params.dig(:batch_id))
    unless report_processor_group.present?
      add_message :error, 'Batch not found'
      return
    end
    
    self.pending_mapping = self.report_processor_group.mappings.not_completed.find_by id: params[:id]
  end

  def validate
    if self.pending_mapping.blank?
      add_message :error, "Request details not found."
      return
    end
  end

  def pre_process
    params[:report_processor_group_mapping].delete([:batch_id])
  end

  def process
    request_params[:marked_as_completed] = !!StringUtils.to_bool(request_params[:marked_as_completed])
    if request_params[:marked_as_completed]
      request_params[:status_id] = MoneyRequestProcessorStatus.id_for(:completed)
      request_params[:completed_at] = DateTime.now
    end
    self.pending_mapping.assign_attributes(request_params)

    if self.pending_mapping.valid?
      self.pending_mapping.save
    else
      add_message :error, self.pending_mapping.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, 'Updated Successfully'
  end

  private

  def request_params
    params.require(:report_processor_group_mapping).permit(:bank_reference_number, :marked_as_completed, :completed_at, :status_id)
  end

end
