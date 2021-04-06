class Notifications::Vp::WeeklyReport::Mailer < Notifier::Mailer

  def self.send_weekly_reports
    from = 1.week.ago.beginning_of_week
    to = 1.week.ago.end_of_week
    UserPanelSubscription.where(weekly_summary_enabled: true).includes(user: :company).each do |subscription|
      user = subscription.user
      next unless user.active? && user.company.status_id == CompanyStatus.id_for(:active)

      Notifications::Vp::WeeklyReport::Mailer.(current_user: user, params: { from: from, to: to })
    end
  end

  schema do
    params do
      required(:from).filled
      required(:to).filled
    end
  end

  assign :to do |user, params|
    # ['vivek.a@finly.io']
    [user.email]
  end

  assign :bcc do |user, params|
    ['vivek.a@finly.io', 'ruchit.shah@finly.io']
  end

  assign :subject do |user, params|
    "Finly Weekly Report: #{params[:from].strftime("%B %d, %Y")} to #{params[:to].strftime("%B %d, %Y")}"
  end

  assign :title do |user, params|
    "Weekly Insights(Beta) for #{user.company.name}"
  end

  assign :sub_header do |user, params|
    "#{params[:from].strftime("%B %d, %Y")} to #{params[:to].strftime("%B %d, %Y")}"
  end

  assign :partial, 'notifier_mailer/partials/report_card'

  assign :hero_bg_icon, 'icon_default'

  assign :hero_bg_image, 'bg_invite'

  assign :report_card do |user, params|
    build_report(user, params)
  end

  protected

  def self.build_report(user, params)
    report_card = {}
    context = { user: user, params: params, from: params[:from], to: params[:to] }

    # Todo update for international currency
    context[:currency] = 'INR'

    build_payments_summary(context, report_card)
    build_payments_by_type(context, report_card)
    build_payments_processed(context, report_card)
    build_top_payments(context, report_card)
    build_overdue_upcoming_invoices(context, report_card)
    build_po_summary(context, report_card)
    build_average_approval_time(context, report_card)
    report_card
  end

  #   payments_summary: {
  #       last_7_days: {
  #         amount: "INR 20cr",
  #         count: '20'
  #       },
  #       month: {
  #         name: "March 2021",
  #         amount: "INR 100cr",
  #         count: 200
  #       }
  #     }
  def self.build_payments_summary(context, report)
    company = context[:user].company
    context[:payments] = company.payments.non_deleted.completed.where(application: 'vp').joins(:amount)
    context[:payments_last_7_days] = payments_last_7_days = context[:payments].where('`payments`.`date` between ? and ?', context[:from], context[:to])

    report[:payments_summary] = { last_7_days: {}, month: {} }
    report[:payments_summary][:last_7_days][:amount] = format_amount(context, payments_last_7_days)
    report[:payments_summary][:last_7_days][:count] = payments_last_7_days.count

    payments_month = company.payments.completed.where('date between ? and ?', context[:from].beginning_of_month, context[:from].end_of_month)
    report[:payments_summary][:month][:name] = context[:from].strftime('%B %Y')
    report[:payments_summary][:month][:amount] = format_amount(context, payments_month)
    report[:payments_summary][:month][:count] = payments_month.count
  end

  #  payments_by_type: {
  #    po_invoice: 30,
  #    non_po_invoice: 20,
  #    agreement_invoice: 10,
  #    po: 20,
  #    utility_bill: 5,
  #    beneficiary_payment: 10,
  #    others: 0
  #  }
  def self.build_payments_by_type(context, report)

    payments_last_7_days = context[:payments_last_7_days]
    payments_last_7_days_invoice = payments_last_7_days.where(parent_type: "Invoice")

    report[:payments_by_type] = {}
    po_invoice_count = payments_last_7_days_invoice.joins(:invoice).where({ invoices: { invoice_type_id: InwardInvoiceType.id_for(:tax_invoice) } }).count
    non_po_invoice_count = payments_last_7_days_invoice.joins(:invoice).where({ invoices: { invoice_type_id: InwardInvoiceType.id_for(:non_po_invoice) } }).count
    agreement_invoice_count = payments_last_7_days_invoice.joins(:invoice, :amount).where({ invoices: { invoice_type_id: InwardInvoiceType.ids_for(:general_invoice, :rental_invoice, :recurring_invoice, :agreement_invoice) } }).count
    po_count = payments_last_7_days.where(parent_type: 'PurchaseOrder').count
    utility_bill_count = payments_last_7_days.where(parent_type: 'BbpsBill').count
    beneficiary_payment_count = payments_last_7_days.where(parent_type: 'BeneficiaryPayment').count
    others_count = payments_last_7_days.where.not(parent_type: %w(BbpsBill BeneficiaryPayment Invoice PurchaseOrder)).count

    total_count = po_invoice_count + non_po_invoice_count + agreement_invoice_count + po_count +
      utility_bill_count + beneficiary_payment_count + others_count

    total_count = 100 if total_count.blank? || total_count == 0

    report[:payments_by_type][:po_invoice] = (po_invoice_count * 100 / total_count).round(2)
    report[:payments_by_type][:non_po_invoice] = (non_po_invoice_count * 100 / total_count).round(2)
    report[:payments_by_type][:agreement_invoice] = (agreement_invoice_count * 100 / total_count).round(2)
    report[:payments_by_type][:po] = (po_count * 100 / total_count).round(2)
    report[:payments_by_type][:utility_bill] = (utility_bill_count * 100 / total_count).round(2)
    report[:payments_by_type][:beneficiary_payment] = (beneficiary_payment_count * 100 / total_count).round(2)
    report[:payments_by_type][:others] = (others_count * 100 / total_count).round(2)

  end

  def self.build_payments_processed(context, report)
    report[:payments_processed] = { months: [] }
    payments = context[:payments].joins(:amount)
                                 .select('sum(`amounts`.`value`) as amount, FLOOR((DayOfMonth(date)-1)/7)+1 as week, DATE_FORMAT(date, "%M %Y") as month')
                                 .where("`payments`.`created_at` > ?", 6.months.ago.beginning_of_month)
                                 .group('week, month')
                                 .order('DATE_FORMAT(date, "%Y-%m") asc, week asc')
                                 .to_sql
    month_data = {}.with_indifferent_access
    raw_data = ActiveRecord::Base.connection.execute(payments).as_json
    row_amount = 0
    row_week_of_month = 1
    row_month = 2
    maximum = 0
    raw_data.each do |row|
      month_data[row[row_month]] ||= { month: row[row_month], total: 0 }.with_indifferent_access
      month_data[row[row_month]]["week_#{row[row_week_of_month]}"] = row[row_amount].to_f
      month_data[row[row_month]]['total'] += row[row_amount].to_f
      if maximum < month_data[row[row_month]]['total']
        maximum = month_data[row[row_month]]['total']
      end
    end

    maximum = maximum.to_i

    month_data.each do |month, data|
      report[:payments_processed][:months] << {
        month: month,
        label: format_currency(context, data['total']),
        percent_of_max: (data['total'] * 100 / maximum).round(2), # Percentage of spend compared to the highest month
        week_1_percentage: (data["week_1"].to_i * 100 / data['total']).round(2), # Percentage of spend of the month,
        week_2_percentage: (data["week_2"].to_i * 100 / data['total']).round(2),
        week_3_percentage: (data["week_3"].to_i * 100 / data['total']).round(2),
        week_4_percentage: (data["week_4"].to_i * 100 / data['total']).round(2),
        week_5_percentage: (data["week_5"].to_i * 100 / data['total']).round(2)
      }
    end

    # Find the maximum expenses in the last 6 months. Multiple it by 1.2 to add some padding
    # This is used for calculating the percentage of all the bars in the bar graph
    report[:payments_processed][:maximum] = maximum * 1.2
  end

  #     top_payments: {
  #       maximum: 100 * 1.2, # 20% more than the highest
  #       payments: [
  #         {
  #           vendor: "ABC Industries",
  #           percent_of_max: 100,
  #           label: "INR 100L",
  #           payment_type: "Non PO Invoice",
  #           color: '#33CC66'
  #         },
  #         {
  #           vendor: "Techno Solutions",
  #           percent_of_max: 50,
  #           label: "INR 50L",
  #           payment_type: "Purchase Order",
  #           color: "#3399FF"
  #         }
  #       ]
  #     }
  def self.build_top_payments(context, report)
    payments_last_7_days = context[:payments_last_7_days]
    top_payments = payments_last_7_days.reorder(value: :desc).limit(5)
    report[:top_payments] = { payments: [], maximum: 0 }

    return if top_payments.size == 0

    colors = [
      Notifications::Vp::WeeklyReport::Job::Colors::ORANGE,
      Notifications::Vp::WeeklyReport::Job::Colors::YELLOW,
      Notifications::Vp::WeeklyReport::Job::Colors::BEIGE,
      Notifications::Vp::WeeklyReport::Job::Colors::BLUE,
      Notifications::Vp::WeeklyReport::Job::Colors::GREEN
    ]

    maximum = report[:top_payments][:maximum] = (top_payments.first.amount.value * 1.2).to_i

    top_payments.each do |payment|
      vendor_name = nil
      case payment.receiving_user_type
      when 'BbpsBillerSubscription'
        vendor_name = payment.receiving_user.name
      when 'YesBankVendor'
        vendor_name = payment.receiving_user.business_name
      end

      vendor_name = "#{vendor_name[0..18]}.." if vendor_name.to_s.length > 22
      vendor_name ||= "-"

      payment_type = payment.parent_type_name
      payment_type = 'PO Advance' if payment_type == 'Purchase Order'

      report[:top_payments][:payments] << {
        vendor: vendor_name,
        percent_of_max: (payment.amount.value * 100 / maximum).round(2),
        label: format_currency(context, payment.amount.value),
        payment_type: payment_type,
        color: colors.shift
      }

    end
  end

  #     overdue_invoices: {
  #       days_0_to_30: {
  #         amount: "INR 20cr",
  #         count: 20,
  #       },
  #       days_30_to_60: {
  #         amount: "INR 20cr",
  #         count: '20',
  #       },
  #       days_60_plus: {
  #         amount: "INR 20cr",
  #         count: '20',
  #       }
  #     }
  #     upcoming_invoices: {
  #       days_0_to_30: {
  #         amount: "INR 20cr",
  #         count: 20,
  #       },
  #       days_30_to_60: {
  #         amount: "INR 20cr",
  #         count: '20',
  #       },
  #       days_60_plus: {
  #         amount: "INR 20cr",
  #         count: '20',
  #       }
  #     }
  def self.build_overdue_upcoming_invoices(context, report)
    invoices = context[:user].company.invoices.where(invoice_type_id: InwardInvoiceType.ids_for(:tax_invoice, :non_po_invoice))
    query = invoices.non_deleted
                    .joins(:vendor, :net_amount)
                    .where(invoice_status_id: InwardInvoiceStatus.ids_for('unpaid', 'partially_paid', 'approved', 'auto_approved'))
                    .select('
        sum(if(DATEDIFF(`invoices`.`due_date`, CURDATE()) < -60, `amounts`.`value`, 0)) as `Overdue > 60 days`,
        sum(if(DATEDIFF(`invoices`.`due_date`, CURDATE()) < -60, 1, 0)) as `Count Overdue > 60 days`,
        sum(if(DATEDIFF(`invoices`.`due_date`, CURDATE()) >= -60 && DATEDIFF(`invoices`.`due_date`, CURDATE()) < -30, `amounts`.`value`, 0)) as `Overdue > 30 days`,
        sum(if(DATEDIFF(`invoices`.`due_date`, CURDATE()) >= -60 && DATEDIFF(`invoices`.`due_date`, CURDATE()) < -30, 1, 0)) as `Count Overdue > 30 days`,
        sum(if(DATEDIFF(`invoices`.`due_date`, CURDATE()) >= -30 && DATEDIFF(`invoices`.`due_date`, CURDATE()) < 0, `amounts`.`value`, 0)) as `Overdue by 0 to 30 days`,
        sum(if(DATEDIFF(`invoices`.`due_date`, CURDATE()) >= -30 && DATEDIFF(`invoices`.`due_date`, CURDATE()) < 0, 1, 0)) as `Count Overdue by 0 to 30 days`,
        sum(if(DATEDIFF(`invoices`.`due_date`, CURDATE()) >= 0 && DATEDIFF(`invoices`.`due_date`, CURDATE()) < 30, `amounts`.`value`, 0)) as ` 0 to 30 days`,
        sum(if(DATEDIFF(`invoices`.`due_date`, CURDATE()) >= 0 && DATEDIFF(`invoices`.`due_date`, CURDATE()) < 30, 1, 0)) as ` Count 0 to 30 days`,
        sum(if(DATEDIFF(`invoices`.`due_date`, CURDATE()) >= 30 && DATEDIFF(`invoices`.`due_date`, CURDATE()) < 60, `amounts`.`value`, 0)) as `30 to 60 days`,
        sum(if(DATEDIFF(`invoices`.`due_date`, CURDATE()) >= 30 && DATEDIFF(`invoices`.`due_date`, CURDATE()) < 60, 1, 0)) as `Count 30 to 60 days`,
        sum(if(DATEDIFF(`invoices`.`due_date`, CURDATE()) >= 60, `amounts`.`value`, 0)) as `60+ days`,
        sum(if(DATEDIFF(`invoices`.`due_date`, CURDATE()) >= 60, 1, 0)) as `Count 60+ days`')
                    .to_sql
    result = ActiveRecord::Base.connection.execute(query).as_json
    row = result[0]
    report[:overdue_invoices] = {
      days_60_plus: {
        amount: format_currency(context, row[0].to_f),
        count: row[1].to_i
      },
      days_30_to_60: {
        amount: format_currency(context, row[2].to_f),
        count: row[3].to_i
      },
      days_0_to_30: {
        amount: format_currency(context, row[4].to_f),
        count: row[5].to_i
      }
    }

    report[:upcoming_invoices] = {
      days_0_to_30: {
        amount: format_currency(context, row[6].to_f),
        count: row[7].to_i
      },
      days_30_to_60: {
        amount: format_currency(context, row[8].to_f),
        count: row[9].to_i
      },
      days_60_plus: {
        amount: format_currency(context, row[10].to_f),
        count: row[11].to_i
      }
    }
  end

  #     po_summary: {
  #       enabled: true,
  #       open_pos: {
  #         amount: "INR 10cr",
  #         count: '40'
  #       },
  #       open_pos_30_days: {
  #         amount: "INR 50cr",
  #         count: '50'
  #       }
  #     }
  def self.build_po_summary(context, report)
    unless context[:user].company.feature_subscription.procurement
      report[:po_summary] = { enabled: false }

      return
    end

    open_pos = context[:user].company.purchase_orders
                             .joins(:net_amount)
                             .where(purchase_order_status_id: PurchaseOrderStatus.ids_for(%i[approved auto_approved sent_to_vendor vendor_confirmed]))
    open_pos_30_days = open_pos.where('approved_at < ?', 30.days.ago.beginning_of_day)

    report[:po_summary] = {
      enabled: true,
      open_pos: {
        amount: format_currency(context, open_pos.sum(:value)),
        count: open_pos.count
      },
      open_pos_30_days: {
        amount: format_currency(context, open_pos_30_days.sum(:value)),
        count: open_pos_30_days.count
      }
    }
  end

  #     avg_approval: {
  #       maximum: 100 * 1.2, # 20% more than the highest
  #       items: [
  #         {
  #           label: "Purchase Requests",
  #           days: 8,
  #           percent_of_max: 80,
  #           color: "#FF6633"
  #         },
  #         {
  #           label: "Purchase Orders",
  #           days: 3,
  #           percent_of_max: 30,
  #           color: "#FFCC33"
  #         },
  #         {
  #           label: "Invoices",
  #           days: 4,
  #           percent_of_max: 40,
  #           color: "#33CC66"
  #         },
  #         {
  #           label: "Vendor Empanelment",
  #           days: 10,
  #           percent_of_max: 100,
  #           color: "#008ce9"
  #         },
  #       ]
  #     }
  def self.build_average_approval_time(context, report)
    report[:avg_approval] = { items: [] }

    company = context[:user].company
    maximum = 0
    if company.feature_subscription.procurement
      if company.feature_subscription.purchase_requisition_system
        pr_days_query = company.purchase_requests.non_deleted
                               .where('approved_at between ? and ?', context[:from].beginning_of_day, context[:to].end_of_day)
                               .select('AVG(DATEDIFF(`approved_at`, `submitted_at`)) as `Days (Avg)`')
                               .to_sql
        pr_days = ActiveRecord::Base.connection.execute(pr_days_query).as_json[0][0].to_f.round(2)
        report[:avg_approval][:items] << {
          label: 'Purchase Requests',
          color: Notifications::Vp::WeeklyReport::Job::Colors::ORANGE,
          days: pr_days
        }
        maximum = pr_days if maximum < pr_days
      end

      po_days_query = company.purchase_orders
                             .non_deleted
                             .where('approved_at between ? and ?', context[:from].beginning_of_day, context[:to].end_of_day)
                             .select('AVG(DATEDIFF(`approved_at`, `submitted_at`)) as `Days (Avg)`')
                             .to_sql
      po_days = ActiveRecord::Base.connection.execute(po_days_query).as_json[0][0].to_f.round(2)
      report[:avg_approval][:items] << {
        label: 'Purchase Orders',
        color: Notifications::Vp::WeeklyReport::Job::Colors::YELLOW,
        days: po_days
      }
      maximum = po_days if maximum < po_days
    end

    inv_days_query = company.invoices.where(invoice_type_id: InwardInvoiceType.ids_for(:tax_invoice, :non_po_invoice))
                            .non_deleted
                            .where('approved_at between ? and ?', context[:from].beginning_of_day, context[:to].end_of_day)
                            .select('AVG(DATEDIFF(`approved_at`, `submitted_at`)) as `Days (Avg)`')
                            .to_sql
    inv_days = ActiveRecord::Base.connection.execute(inv_days_query).as_json[0][0].to_f.round(2)
    report[:avg_approval][:items] << {
      label: 'Invoices',
      color: Notifications::Vp::WeeklyReport::Job::Colors::BEIGE,
      days: inv_days
    }
    maximum = inv_days if maximum < inv_days

    pt_days_query = company.bank_payment_requests
                           .non_deleted
                           .where('approved_at between ? and ?', context[:from].beginning_of_day, context[:to].end_of_day)
                           .select('AVG(DATEDIFF(`approved_at`, `submitted_at`)) as `Days (Avg)`')
                           .to_sql
    pt_days = ActiveRecord::Base.connection.execute(pt_days_query).as_json[0][0].to_f.round(2)
    report[:avg_approval][:items] << {
      label: 'Payment Tickets',
      color: Notifications::Vp::WeeklyReport::Job::Colors::BLUE,
      days: pt_days
    }
    maximum = pt_days if maximum < pt_days

    vndr_days_query = company.yes_bank_vendors
                             .non_deleted
                             .where('approved_at between ? and ?', context[:from].beginning_of_day, context[:to].end_of_day)
                             .select('AVG(DATEDIFF(`approved_at`, `submitted_at`)) as `Days (Avg)`')
                             .to_sql
    vndr_days = ActiveRecord::Base.connection.execute(vndr_days_query).as_json[0][0].to_f.round(2)
    report[:avg_approval][:items] << {
      label: 'Vendor Empanelment',
      color: Notifications::Vp::WeeklyReport::Job::Colors::GREEN,
      days: vndr_days
    }
    maximum = vndr_days if maximum < vndr_days
    report[:avg_approval][:maximum] = (maximum * 1.2).to_i

    return if maximum == 0
    report[:avg_approval][:items].each do |item|
      item[:percent_of_max] = (item[:days] * 100 / maximum).round(2)
    end
  end

  private

  def self.format_amount(context, payments)
    if payments.count > 0
      format_currency(context, (payments.joins(:amount).sum(:value)))
    else
      format_currency(context, 0)
    end
  end

  def self.format_currency(context, value)
    "#{context[:currency]} #{(value / 100000).round(2)}L"
  end

  # payload = {
  #   report_card: {
  #     currency: "INR",
  #     payments_summary: {
  #       this_week: {
  #         amount: "INR 20cr",
  #         count: '20'
  #       },
  #       this_month: {
  #         amount: "INR 100cr",
  #         count: 200
  #       }
  #     },
  #     payments_by_type: {
  #       po_invoice: 30,
  #       non_po_invoice: 20,
  #       agreement_invoice: 10,
  #       po: 20,
  #       utility_bill: 5,
  #       beneficiary_payment: 10,
  #       others: 0
  #     },
  #     payments_processed: {
  #       maximum: 100 * 1.2, # 20% more than the highest
  #       months: [
  #         {
  #           month: "October 2020",
  #           label: "INR 4cr",
  #           percent_of_max: 100, # Percentage of spend compared to the highest month
  #           week_1_percentage: 40, # Percentage of spend of the month,
  #           week_2_percentage: 11,
  #           week_3_percentage: 18,
  #           week_4_percentage: 31,
  #         },
  #         {
  #           month: "November 2020",
  #           percent_of_max: 30,
  #           label: "INR 3cr",
  #           week_1_percentage: 30,
  #           week_2_percentage: 41,
  #           week_3_percentage: 29,
  #           week_4_percentage: 0,
  #         },
  #         {
  #           month: "December 2020",
  #           percent_of_max: 20,
  #           label: "INR 4.1cr",
  #           week_1_percentage: 30,
  #           week_2_percentage: 41,
  #           week_3_percentage: 11,
  #           week_4_percentage: 18
  #         }
  #       ]
  #     },
  #     top_payments: {
  #       maximum: 100 * 1.2, # 20% more than the highest
  #       payments: [
  #         {
  #           vendor: "ABC Industries",
  #           percent_of_max: 100,
  #           label: "INR 100L",
  #           payment_type: "Non PO Invoice",
  #           color: '#33CC66'
  #         },
  #         {
  #           vendor: "Techno Solutions",
  #           percent_of_max: 50,
  #           label: "INR 50L",
  #           payment_type: "Purchase Order",
  #           color: "#3399FF"
  #         }
  #       ]
  #     },
  #     overdue_invoices: {
  #       days_0_to_30: {
  #         amount: "INR 20cr",
  #         count: '20'
  #       },
  #       days_30_to_60: {
  #         amount: "INR 20cr",
  #         count: '20'
  #       },
  #       days_60_to_90: {
  #         amount: "INR 20cr",
  #         count: '20'
  #       }
  #     },
  #     upcoming_invoices: {
  #       days_0_to_30: {
  #         amount: "INR 30cr",
  #         count: '40'
  #       },
  #       days_30_to_60: {
  #         amount: "INR 20cr",
  #         count: '30'
  #       },
  #       days_60_to_90: {
  #         amount: "INR 10cr",
  #         count: '20'
  #       }
  #     },
  #     po_summary: {
  #       enabled: true,
  #       open_pos: {
  #         amount: "INR 10cr",
  #         count: '40'
  #       },
  #       open_pos_30_days: {
  #         amount: "INR 50cr",
  #         count: '50'
  #       }
  #     },
  #     avg_approval: {
  #       maximum: 100 * 1.2, # 20% more than the highest
  #       items: [
  #         {
  #           label: "Purchase Requests",
  #           days: 8,
  #           percent_of_max: 80,
  #           color: "#FF6633"
  #         },
  #         {
  #           label: "Purchase Orders",
  #           days: 3,
  #           percent_of_max: 30,
  #           color: "#FFCC33"
  #         },
  #         {
  #           label: "Invoices",
  #           days: 4,
  #           percent_of_max: 40,
  #           color: "#33CC66"
  #         },
  #         {
  #           label: "Vendor Empanelment",
  #           days: 10,
  #           percent_of_max: 100,
  #           color: "#008ce9"
  #         },
  #       ]
  #     }
  #   }
  # }

end