require 'rack/test'
require 'json'
require_relative '../../app/api'

# Acceptance tests exercise ALL layers of the app

module ExpenseTracker
  RSpec.describe 'Expense Tracker API' do
    include Rack::Test::Methods

    def app
      ExpenseTracker::API.new
    end

    def post_expense(expense)
      post '/expenses', JSON.generate(expense)
      expect(last_response.status).to eq(200)

      response = JSON.parse(last_response.body)

      expect(response).to include('expense_id' => a_kind_of(Integer))
      expense.merge('id' => response['expense_id']) # add id key to hash, with whatever ID is returned from the DB
    end

    it 'records submitted expenses' do
      coffee = post_expense(
        'payee' => 'Starbucks',
        'amount' => 5.75,
        'date' => '2020-01-29'
      )

      zoo = post_expense(
        'payee' => 'SB Zoo',
        'amount' => 20.00,
        'date' => '2020-01-29'
      )

      groceries = post_expense(
        'payee' => 'Whole Foods',
        'amount' => 55.70,
        'date' => '2020-01-20'
      )

      get '/expenses/2020-01-29'
      expenses = JSON.parse(last_response.body)

      expect(last_response.status).to eq(200)
      expect(expenses).to contain_exactly(coffee, zoo) # check an array contains only the two expenses we want, regardless of order
    end
  end
end
