class Personalizer::Adapters::Company196::ExportTemplates196::Config

  def self.templates
    {
        quick_book_template: {
            class: Personalizer::Adapters::Company196::ExportTemplates196::QuickBookTemplate,
            name: 'Quick Book Input Invoices ',
            description: 'Qucik Book. Export invoices those are approved',
            formats: [
                {name: 'Export as CSV', extension: 'csv'},
                {name: 'Export as XLS', extension: 'xls'}
            ]
        }

    }
  end

end