# Preview all emails at http://localhost:3000/rails/mailers/export_job
class NotifierMailerPreview < ActionMailer::Preview

  # http://localhost:3001/rails/mailers/notifier_mailer/send_report_card_mail
  def send_report_card_mail
    payload = {
      partial: 'notifier_mailer/partials/report_card',
      company: {
        name: "Test Company"
      },
      hero_bg_image: 'bg_invite',
      title: "Weekly Update for Quikr",
      sub_header: "November 1st, 2020 - November 7th, 2020",
      to: ["viveka@finly.io"],
      report_card: {
        currency: "INR",
        payments_summary: {
          this_week: {
            amount: "INR 20cr",
            count: '20'
          },
          this_month: {
            amount: "INR 100cr",
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
          maximum: 100, # Highest spend in all the months
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
              week_3_percentage:  11,
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
          maximum: 100,
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
        }
      }
    }
    NotifierMailer.send_mail(payload.to_json.to_s)
  end

end
