class Personalizer::Adapters::Company164::ExportTemplates164::Config

  def self.templates
    {
        lms: {
            class: Personalizer::Adapters::Company164::ExportTemplates164::SapTemplate,
            name: 'LMS Accounting',
            description: 'LMS exportable format. Exports expenses',
            formats: [
                {name: 'Export as CSV', extension: 'csv'},
                {name: 'Export as XLS', extension: 'xls'}
            ]
        }
    }
  end

end