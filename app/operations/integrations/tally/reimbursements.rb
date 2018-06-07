class Integrations::Tally::Reimbursements < Integrations::Tally::Base
  attr_accessor :report_processor_groups

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless current_company.tally_configuration.present? and current_company.tally_configuration.active
      add_message :error, 'Tally integration has not been configured for your company'
      return
    end
    if params[:id].blank? and not params[:filtered]
      add_message :error, 'Report not found'
      return
    end
  end

  def process
    processor_group_presenter = Settlement::SReport::Completed::BatchIndex.(user, params)
    unless processor_group_presenter&.success?
      add_message :error, processor_group_presenter.messages[:error]
      return
    end
    self.report_processor_groups = processor_group_presenter.report_processor_groups
    if params[:filtered]
      self.report_processor_groups = self.report_processor_groups.processed
    else
      id = params[:id] || params[:report_id]
      id = id.split(',')
      self.report_processor_groups = self.report_processor_groups.with_id(id)
    end
    if user.company.tally_configuration.custom_voucher
      template = "#{Rails.root}/lib/personalizer/adapters/company#{user.company_id}/tally/reimbursements.xml"
    else
      current_class_path = self.method(:success).source_location.first.gsub('/reimbursements.rb', '')
      template = "#{current_class_path}/reimbursements.xml"
    end
    self.response = Exporter.new(user, {xml: {template: template, local_variables: {report_processor_groups: self.report_processor_groups, configuration: current_company.tally_configuration}}}, messages)
  end

  def post_process
    self.report_processor_groups.update_all(tally_exported: true)
  end

  def success
    self.response
  end

  # class Personalizer::Adapters::Company2::ExportTemplates2::Tally::Presenter < Exporter
  #
  #   def render(controller)
  #     controller.send_data 'this, is, a, test, csv', file_name: 'hello.csv'
  #   end
  #
  # end

end


