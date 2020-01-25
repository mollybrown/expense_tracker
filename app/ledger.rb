require_relative '../config/sequel'

module ExpenseTracker
  # Moved from spec
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  class Ledger
    VALID_KEYS = ['payee', 'amount', 'date'].freeze

    def record(expense)
      if expense.keys != VALID_KEYS
        RecordResult.new(false, nil, error_message(expense))
      else
        DB[:expenses].insert(expense)
        id = DB[:expenses].max(:id)
        RecordResult.new(true, id, nil)
      end
    end

    def expenses_on(date)
      DB[:expenses].where(date: date).all
    end

    private

    def error_message(expense)
      reason = []
      reason << '`payee` is required' if expense["payee"].nil?
      reason << '`amount` is required' if expense["amount"].nil?
      reason << '`date` is required' if expense["date"].nil?

      return "Invalid Expense: #{reason}"
    end
  end
end
