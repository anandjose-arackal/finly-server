class Personalizer::Adapters::Company1::ExportTemplates1::Config

  def self.templates
    {
        tally: {
            class: Personalizer::Adapters::Company1::ExportTemplates1::Tally,
            name: 'Tally',
            description: 'Tally exportable format. Exports expenses',
            formats: [
                {name: 'Export as Excel', extension: 'xls'},
                {name: 'Export as CSV', extension: 'csv'}
            ]
        },
        sap: {
            class: Personalizer::Adapters::Company1::ExportTemplates1::Sap,
            name: 'SAP Accounting',
            description: 'SAP Account format. Exports expenses',
            formats: [
                {name: 'Export for SAP', extension: 'csv'}
            ]
        },
        quickbooks: {
            class: Personalizer::Adapters::Company1::ExportTemplates1::Quickbooks,
            name: 'Quickbooks',
            description: 'Quickbooks Online Export',
            formats: [
                {name: 'Export to Quickbooks', extension: 'xls'}
            ]
        },
        tally_journal: {
            class: Personalizer::Adapters::Company1::ExportTemplates1::TallyJournalTemplate,
            name: 'Tally Journal Uploader of Purchase',
            description: 'Tally exportable format.',
            formats: [
                {name: 'Export as XLS', extension: 'xls'}
            ]
        }
    }
  end

end