class Personalizer::Adapters::Company234::ExportTemplates234::Config

  def self.templates
    {

        jv_expenses_export: {
            class: Personalizer::Adapters::Company234::ExportTemplates234::JVExporter,
            name: 'J V Approved Expenses',
            description: 'J V exportable format. Export expenses those are approved',
            formats: [
                {name: 'Export as XLS', extension: 'xls'}
            ]
        }

    }
  end

end