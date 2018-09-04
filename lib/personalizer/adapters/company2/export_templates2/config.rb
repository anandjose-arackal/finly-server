class Personalizer::Adapters::Company2::ExportTemplates2::Config

  def self.templates
    {
        sap: {
            class: Personalizer::Adapters::Company2::ExportTemplates2::SapTemplate,
            name: 'SAP',
            description: 'SAP exportable format. Exports expenses',
            formats: [
                {name: 'Export as CSV', extension: 'csv'},
                {name: 'Export as XLS', extension: 'xls'}
            ]
        }
    }
  end

end