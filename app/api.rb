require 'sinatra/base'
require 'json'

module ExpenseTracker
  class API < Sinatra::Base
    post '/expenses' do
      JSON.generate('expense_id' => 42)
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
