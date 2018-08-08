class Personalizer::Adapters::Company112::ExportTemplates112::Config

  def self.templates
    {
        sap: {
            class: Personalizer::Adapters::Company112::ExportTemplates112::SapTemplate,
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