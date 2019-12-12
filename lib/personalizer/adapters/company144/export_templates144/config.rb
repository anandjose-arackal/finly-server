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
        },
        tally_journal: {
            class: Personalizer::Adapters::Company144::ExportTemplates144::TallyJournalTemplate,
            name: 'Tally Journal Uploader',
            description: 'Tally exportable format.',
            formats: [
                {name: 'Export as XLS', extension: 'xls'}
            ]
        }

    }
  end

end