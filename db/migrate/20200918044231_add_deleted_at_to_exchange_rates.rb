class AddDeletedAtToExchangeRates < ActiveRecord::Migration[5.2]
  def change
    ExchangeRate.migrate_to_paranoid
  end
end
