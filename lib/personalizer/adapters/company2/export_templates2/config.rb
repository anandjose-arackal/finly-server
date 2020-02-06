class Personalizer::Adapters::Company2::ExportTemplates2::Config

  def self.templates
    {
        sap: {
            class: Personalizer::Adapters::Company2::ExportTemplates2::SapTemplate,
            name: 'SAP',
            description: 'SAP exportable format. Exports expenses',
            formats: [
                {name: 'Export as CSV', extension: 'csv'},
                {name: 'Export as XLS', extension: 'xls'}
            ]
        },
        tally_journal: {
            class: Personalizer::Adapters::Company2::ExportTemplates2::TallyJournalTemplate,
            name: 'Tally Journal Uploader',
            description: 'Tally exportable format.',
            formats: [
                {name: 'Export as XLS', extension: 'xls'}
            ]
        },
        lms_invoices: {
            class: Personalizer::Adapters::Company2::ExportTemplates2::InvoicesTemplate,
            name: 'L M S  Approved Invoices ',
            description: 'LMS exportable format. Export invoices those are approved',
            formats: [
                {name: 'Export as CSV', extension: 'csv'},
                {name: 'Export as XLS', extension: 'xls'}
            ]
        }
    }
  end

end