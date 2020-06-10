class Personalizer::Adapters::Company137::ExportTemplates137::Config

  def self.templates
    {
      tally_journal: {
        class: Personalizer::Adapters::Company137::ExportTemplates137::TallyJournalTemplate,
        name: 'Tally Journal Uploader of Purchase',
        description: 'Tally exportable format.',
        formats: [
          {name: 'Export as XLS', extension: 'xls'}
        ]
      }
    }
  end

end