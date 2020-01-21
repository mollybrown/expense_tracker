require 'sinatra/base'
require 'json'

module ExpenseTracker
  class API < Sinatra::Base
    def initialize(ledger: Ledger.new)
      @ledger = ledger
      super()
    end

    post '/expenses' do
      expense = JSON.parse(request.body.read)
      result = @ledger.record(expense)

      JSON.generate('expense_id' => result.expense_id)
    end

    get '/expenses/:date' do
      JSON.generate([
          {
            'payee' => 'Starbucks',
            'amount' => 5.75,
            'date' => '2020-01-29',
            'id' => 42
          },
          {
            'payee' => 'SB Zoo',
            'amount' => 20.00,
            'date' => '2020-01-29',
            'id' => 42
          }
        ])
    end
  end
end
