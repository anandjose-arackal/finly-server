# Preview all emails at http://localhost:3000/rails/mailers/export_job
class NotifierMailerPreview < ActionMailer::Preview

  # http://localhost:3001/rails/mailers/notifier_mailer/send_report_card_mail
  def send_report_card_mail
    payload = {
      partial: 'notifier_mailer/partials/report_card',
      company: {
        name: "Test Company"
      },
      hero_bg_icon: 'icon_default',
      hero_bg_image: 'bg_invite',
      title: "Weekly Update for Quikr",
      sub_header: "November 1st, 2020 - November 7th, 2020",
      to: ["viveka@finly.io"],
      report_card: {
        currency: "INR",
        payments_summary: {
          last_7_days: {
            amount: 'INR 20cr',
            count: '20'
          },
          month: {
            name: 'March 2021',
            amount: 'INR 100cr',
            count: 200
          }
        },
        payments_by_type: {
          po_invoice: 30,
          non_po_invoice: 20,
          agreement_invoice: 10,
          po: 20,
          utility_bill: 5,
          beneficiary_payment: 10,
          others: 0
        },
        payments_processed: {
          maximum: 100 * 1.2, # 20% more than the highest
          months: [
            {
              month: "October 2020",
              label: "INR 4cr",
              percent_of_max: 100, # Percentage of spend compared to the highest month
              week_1_percentage: 40, # Percentage of spend of the month,
              week_2_percentage: 11,
              week_3_percentage: 18,
              week_4_percentage: 31,
            },
            {
              month: "November 2020",
              percent_of_max: 30,
              label: "INR 3cr",
              week_1_percentage: 30,
              week_2_percentage: 41,
              week_3_percentage: 29,
              week_4_percentage: 0,
            },
            {
              month: "December 2020",
              percent_of_max: 20,
              label: "INR 4.1cr",
              week_1_percentage: 30,
              week_2_percentage: 41,
              week_3_percentage: 11,
              week_4_percentage: 18
            },
            {
              month: "January 2021",
              percent_of_max: 70,
              label: "INR 3cr",
              week_1_percentage: 30,
              week_2_percentage: 41,
              week_3_percentage: 11,
              week_4_percentage: 18,
            },
            {
              month: "February 2021",
              label: "INR 3cr",
              week_1_percentage: 30,
              week_2_percentage: 41,
              week_3_percentage: 11,
              week_4_percentage: 18,
            },
            {
              month: "March 2021",
              label: "INR 3cr",
              week_1_percentage: 30,
              week_2_percentage: 41,
              week_3_percentage: 11,
              week_4_percentage: 18,
            }
          ]
        },
        top_payments: {
          maximum: 100 * 1.2, # 20% more than the highest
          payments: [
            {
              vendor: "ABC Industries",
              percent_of_max: 100,
              label: "INR 100L",
              payment_type: "Non PO Invoice",
              color: '#33CC66'
            },
            {
              vendor: "Techno Solutions",
              percent_of_max: 50,
              label: "INR 50L",
              payment_type: "Purchase Order",
              color: "#3399FF"
            },
            {
              vendor: "Rock Nation",
              percent_of_max: 30,
              label: "INR 30L",
              payment_type: "Agreement Invoice",
              color: "#FFCC33"
            },
            {
              vendor: "Sleepy Cat",
              percent_of_max: 10,
              label: "INR 10L",
              payment_type: "Agreement Invoice",
              color: "#FF6633"
            },
            {
              vendor: "Sleepy Top",
              percent_of_max: 10,
              label: "INR 0.80L",
              payment_type: "Agreement Invoice",
              color: "#3C4A3E"
            }
          ]
        },
        overdue_invoices: {
          days_0_to_30: {
            amount: "INR 20cr",
            count: '20'
          },
          days_30_to_60: {
            amount: "INR 20cr",
            count: '20'
          },
          days_60_plus: {
            amount: "INR 20cr",
            count: '20'
          }
        },
        upcoming_invoices: {
          days_0_to_30: {
            amount: "INR 30cr",
            count: '40'
          },
          days_30_to_60: {
            amount: "INR 20cr",
            count: '30'
          },
          days_60_plus: {
            amount: "INR 10cr",
            count: '20'
          }
        },
        po_summary: {
          enabled: true,
          open_pos: {
            amount: "INR 10cr",
            count: '40'
          },
          open_pos_30_days: {
            amount: "INR 50cr",
            count: '50'
          }
        },
        avg_approval: {
          maximum: 100 * 1.2, # 20% more than the highest
          items: [
            {
              label: "Purchase Requests",
              days: 8,
              percent_of_max: 80,
              color: "#FF6633"
            },
            {
              label: "Purchase Orders",
              days: 3,
              percent_of_max: 30,
              color: "#FFCC33"
            },
            {
              label: "Invoices",
              days: 4,
              percent_of_max: 40,
              color: "#33CC66"
            },
            {
              label: "Vendor Empanelment",
              days: 10,
              percent_of_max: 100,
              color: "#008ce9"
            },
          ]
        }
      }
    }
    payload[:report_card] = Notifications::Vp::WeeklyReport::Mailer.build_report(User.first, {from: 7.days.ago.beginning_of_day, to: Date.today.end_of_day})
    NotifierMailer.send_mail(payload.to_json.to_s)
  end

end
