class ExportManager::Master::ReportsPdf::Index < ExportManager::Builders::Pdf

  label 'Export'
  description 'Report Export Pdf'
  configurable true
  system :em
  screen 'reports.index'
  handle :reports_pdf

  def generate_pdf
    update({total_records: 1})
    op = ::Reports::ExportHandler.(user, params)
    local_variables = op.local_variables
    template = op.template
    local_variables[:op] = op
    @result = Exporter::Pdf.new(user, {filename: "report-#{op.report.name}", layout: 'pdf.html.erb', template: template, local_variables: local_variables})
    progress_update(1)
    file = @result.render_pdf_file
  end
end