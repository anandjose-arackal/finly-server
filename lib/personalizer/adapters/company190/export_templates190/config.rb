class Personalizer::Adapters::Company190::ExportTemplates190::Config

  def self.templates
    {
        processed_expenses: {
            class: Personalizer::Adapters::Company190::ExportTemplates190::ExpenseExportTemplate,
            name: 'Processed Reports',
            description: 'Exports expenses',
            formats: [
                {name: 'Export as CSV', extension: 'csv'},
                {name: 'Export as XLS', extension: 'xls'}
            ]
        }
    }
  end

end