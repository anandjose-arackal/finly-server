#
# This would check for possible matches and give 3 types of suggestions.
# 1. Suggested match [Single]
# 2. Closest matches [Multiple]
# 3. Other possible matches [Multiple]
# 4. All card expenses
#
#
# Possible - Within 15hours of the receipt time if time is available or pick the one with the same date
# Closest matches
#   - amount with a 1% variation or 1 different which ever is higher
#   - time within 30 mins of the bill being generated
# Suggested match - If multiple possible matches, pick one based on
#   - Pick one based on closest amount
#   - If both have the same amounts, pick one based on closest timestamp if available

class Transcriber::Receipts::DataExtract::MatchExpense < Transcriber::Receipts::DataExtract::Base
  attr_accessor :receipt_extract, :card_expenses, :suggested_match, :closest_matches, :possible_matches, :card_transactions

  CONFIG = {
      POSSIBLE_MATCHES_RANGE: {
          START_TIME_DIFF: 15.hours,
          END_TIME_DIFF: 15.hours
      },
      CLOSEST_MATCHES_RANGE: {
          START_TIME_DIFF: 30.minutes,
          END_TIME_DIFF: 30.minutes,
          AMOUNT_RANGE: {
              PERCENTAGE: 1,
              MINIMUM_VALUE: 1
          }
      }
  }

  def pre_validate
    if params.blank? or params[:receipt_extract].blank?
      add_message :error, 'Receipt Extract not found'
      return
    end
  end

  def init
    self.receipt_extract = params[:receipt_extract]
    self.card_expenses = self.receipt_extract&.receipt.user.expenses.only_card_expenses
    card_transcation_ids = self.card_expenses.pluck_card_transaction_id
    self.card_transactions = CardTransaction.with_id(card_transcation_ids)
  end

  def validate
    if self.receipt_extract.illegible
      add_message :error, 'Receipt cannot be mapped to an expense'
      return
    end
  end

  def process
    date = self.receipt_extract.date
    time = self.receipt_extract.time
    amount_value = self.receipt_extract.amount&.value

    compute_possible_matches(date, time, amount_value)
    compute_closest_matches(date, time, amount_value) if self.possible_matches.present?
    compute_suggested_match(date, time, amount_value) if self.closest_matches.present?
  end

  def compute_possible_matches(date, time, amount_value)
    if date.present? and time.present?
      datetime = DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec, time.zone)
      start_datetime = datetime - CONFIG[:POSSIBLE_MATCHES_RANGE][:START_TIME_DIFF]
      end_datetime = datetime + CONFIG[:POSSIBLE_MATCHES_RANGE][:END_TIME_DIFF]

      filtered_card_transaction_ids = self.card_transactions.with_transaction_timestamp_range(start_datetime, end_datetime).pluck(:id)
      self.possible_matches = self.card_expenses.with_id(filtered_card_transaction_ids)
    elsif date.present?
      self.possible_matches = self.card_expenses.with_date(date)
    end
  end

  def compute_closest_matches(date, time, amount_value)
    return unless self.possible_matches.present?
    matches = nil
    if date.present? and time.present?
      datetime = DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec, time.zone)
      start_datetime = datetime - CONFIG[:CLOSEST_MATCHES_RANGE][:START_TIME_DIFF]
      end_datetime = datetime + CONFIG[:CLOSEST_MATCHES_RANGE][:END_TIME_DIFF]

      filtered_card_transaction_ids = self.card_transactions.with_transaction_timestamp_range(start_datetime, end_datetime).pluck(:id)
      matches = self.card_expenses.with_id(filtered_card_transaction_ids)
    end

    if amount_value.present?
      matches = self.possible_matches if matches.nil?

      amount_diff = amount_value * CONFIG[:CLOSEST_MATCHES_RANGE][:AMOUNT_RANGE][:PERCENTAGE]
      min_value = CONFIG[:CLOSEST_MATCHES_RANGE][:AMOUNT_RANGE][:MINIMUM_VALUE]
      amount_diff = min_value if amount_diff < min_value
      amount_range_start = amount_value - amount_diff
      amount_range_end = amount_value + amount_diff
      amount_range_start = amount_value if amount_range_start < 1

      matches = matches.filter_amount('gteq', amount_range_start).filter_amount('lteq', amount_range_end)
    end

    self.closest_matches = matches
  end

  def compute_suggested_match(date, time, amount_value)
    return if closest_matches.blank?
  end

  def success

  end

  class Transcriber::Receipts::DataExtract::MatchExpense::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :suggested_match, :closest_matches, :possible_matches
  end

end