class ReminderOutwardInvoices < ApplicationJob

  def perform
    outward_invoices = OutwardInvoice.exclude_deleted.unpaid

    for invoice in outward_invoices
      params = {
          outward_invoice_id: invoice.id
      }
      # result = Event::EOutwardInvoice::Reminder(nil, params)
      reminders = InvoiceReminder.with_id invoice.reminders
      for reminder in reminders
        p Date.today, get_reminder_date(invoice, reminder)
        if Date.today == get_reminder_date(invoice, reminder)
          result = Event::EOutwardInvoice::Remind.(nil, params)
        end
      end
    end
  end

  private

  def get_reminder_date(invoice, reminder)
    date = nil
    if reminder.timeframe_type == 'before'
      if reminder.reference_date_type == 'due_date'
        date = invoice.due_date - reminder.days.days
      elsif reminder.reference_date_type == 'date'
        date = invoice.date - reminder.days.days
      end

    elsif reminder.timeframe_type == 'after'
      if reminder.reference_date_type == 'due_date'
        date = invoice.due_date + reminder.days.days
      elsif reminder.reference_date_type == 'date'
        date = invoice.date + reminder.days.days
      end
    end
  end

end
