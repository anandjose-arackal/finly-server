class Notifier::Broadcaster

  attr_accessor :user, :params

  def initialize(user, params)
    self.user, self.params = user, params
  end

  def self.call(user, params)
    self.new(user, params).process
  end

  def process
    event = params[:event]
    document = params[:document]
    options = {
        previous_state: params[:previous_state]
    }

    routes(params[:event]&.to_sym).each do |route|
      event_channel = document.class.respond_to?(:event_channel) ? document.class.event_channel : document.class.table_name
      Events::Publisher.broadcast "#{event_channel}.#{event}.#{route}",
                                  Events::Payload::Record.(document, user, event, options),
                                  current_user: user
    end
  end

  def routes(event)
    data[event]
  end

  def data
    {
        submit: ['submitted_to', 'submitted_from'],
        retract: ['retracted_from', 'retracted_by'],
        approve: ['approved_by', 'approved_to', 'approved_for'],
        take_control: ['taken_control_by', 'taken_control_from'],
        return_control: ['returned_control_by', 'returned_control_from'],
        reject: ['rejected_by', 'rejected_to'],
        unapproved: ['unapproved_by', 'unapproved_for'],
        close: ['closed_by', 'closed_for'],
        void: ['voided_by', 'voided_for'],
        reopen: ['reopened_by', 'reopened_for'],
        hold: ['held_by', 'held_for'],
        release: ['released_by', 'released_for'],
        create_payment_ticket: ['payment_ticket_created_by', 'payment_ticket_created_for'],
        deactivate: ['deactived_by', 'deactivated_for'],
        reactivate: ['reactivated_by', 'reactivated_for'],
        # new_bill: ['autofetched', 'manual'],
        new_bill: ['autofetched']
    }
  end

end