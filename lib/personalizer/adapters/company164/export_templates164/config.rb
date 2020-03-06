class Personalizer::Adapters::Company164::ExportTemplates164::Config

  def self.templates
    {
        lms: {
            class: Personalizer::Adapters::Company164::ExportTemplates164::SapTemplate,
            name: 'LMS Accounting',
            description: 'LMS exportable format. Exports expenses',
            formats: [
                {name: 'Export as CSV', extension: 'csv'},
                {name: 'Export as XLSX', extension: 'xlsx'}
            ]
        },
        jv_settled_expense: {
            class: Personalizer::Adapters::Company164::ExportTemplates164::SettledExpenseTemplate,
            name: 'JV Expense on Processed',
            description: 'J V exportable format. Exports expenses on settlement',
            formats: [
                {name: 'Export as CSV', extension: 'csv'},
                {name: 'Export as XLS', extension: 'xls'}
            ]
        },
        jv_settled_money_request: {
            class: Personalizer::Adapters::Company164::ExportTemplates164::SettledMoneyRequestTemplate,
            name: 'J V Settled Money Request',
            description: 'J V exportable format. Exports money requests settled through bank payment',
            formats: [
                {name: 'Export as CSV', extension: 'csv'},
                {name: 'Export as XLS', extension: 'xls'}
            ]
        },
        jv_reimbursed_expense: {
            class: Personalizer::Adapters::Company164::ExportTemplates164::ReimbursedExpenseTemplate,
            name: 'J V Settled Expenses ',
            description: 'J V exportable format. Export expenses reimbursed through bank payment',
            formats: [
                {name: 'Export as CSV', extension: 'csv'},
                {name: 'Export as XLS', extension: 'xls'}
            ]
        },
        lms_invoices: {
            class: Personalizer::Adapters::Company164::ExportTemplates164::InvoicesTemplate,
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