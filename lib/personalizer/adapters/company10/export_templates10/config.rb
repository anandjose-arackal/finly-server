class Personalizer::Adapters::Company10::ExportTemplates10::Config

  def self.templates
    {
        sap: {
            class: Personalizer::Adapters::Company10::ExportTemplates10::AllStatementsTemplate,
            name: 'All Statements',
            description: 'Export all statements in a single file',
            formats: [
                {name: 'Export as CSV', extension: 'csv'},
                {name: 'Export as XLS', extension: 'xls'}
            ]
        }
    }
  end

end