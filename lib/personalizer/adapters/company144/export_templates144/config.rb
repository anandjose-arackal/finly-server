class Personalizer::Adapters::Company144::ExportTemplates144::Config

  def self.templates
    {
        tally: {
            class: Personalizer::Adapters::Company144::ExportTemplates144::TallyTemplate,
            name: 'Tally',
            description: 'Tally exportable format. Exports expenses',
            formats: [
                {name: 'Export as XLS', extension: 'xls'}
            ]
        }
    }
  end

end