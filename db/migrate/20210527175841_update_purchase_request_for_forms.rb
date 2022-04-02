class UpdatePurchaseRequestForForms < ActiveRecord::Migration[6.0]
  def change

    # unless ActiveRecord::Base.connection.column_exists?(:purchase_requests, :creator_name)
    #   add_column :purchase_requests, :creator_name, :string
    # end

    # unless ActiveRecord::Base.connection.column_exists?(:purchase_requests, :creator_email)
    #   add_column :purchase_requests, :creator_email, :string
    # end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_requests, :conversion_date)
      add_column :purchase_requests, :conversion_date, :date
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_requests, :reporting_currency_id)
      add_column :purchase_requests, :reporting_currency_id, :integer
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_requests, :base_currency_id)
      add_column :purchase_requests, :base_currency_id, :integer
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_requests, :conversion_rate)
      add_column :purchase_requests, :conversion_rate, :decimal, :precision => 20, :scale => 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_requests, :pr_gross_amount)
      add_column :purchase_requests, :pr_gross_amount, :decimal, :precision => 20, :scale => 5
    end

    unless ActiveRecord::Base.connection.column_exists?(:purchase_requests, :reporting_pr_gross_amount)
      add_column :purchase_requests, :reporting_pr_gross_amount, :decimal, :precision => 20, :scale => 5
    end

  end
end
