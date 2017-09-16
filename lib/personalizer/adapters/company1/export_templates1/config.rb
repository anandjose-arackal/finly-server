class Personalizer::Adapters::Company1::ExportTemplates1::Config

  def self.templates
    {
        tally: {
            class: Personalizer::Adapters::Company1::ExportTemplates1::Tally,
            name: 'Tally',
            description: 'Tally exportable format. Exports expenses',
            formats: [:csv]
            # formats: [:xls, :csv]
        }
    }
  end

end