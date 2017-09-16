class Personalizer::Adapters::Company2::ExportTemplates2::Config

  def self.templates
    {
        tally: {
            class: Personalizer::Adapters::Company2::ExportTemplates2::Tally,
            name: 'Tally',
            description: 'Tally exportable format. Exports expenses',
            formats: [
                {name: 'Export as Excel', extension: 'xls'},
                {name: 'Export as CSV', extension: 'csv'}
            ]
            # formats: [:xls, :csv]
        }
    }
  end

end