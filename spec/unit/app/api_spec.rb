require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    def response
      JSON.parse(last_response.body)
    end

    # Create stand-in for instance of ExpenseTracker::Ledger class
    # Test double defines the interface that the Ledger class needs to provide
    let(:ledger) { instance_double('ExpenseTracker::Ledger') }
    let(:expense) { expense = { 'some' => 'data' } }

    describe 'GET /expenses/:date' do
      context 'when expenses exist on the given date' do
        before do
          allow(ledger).to receive(:expenses_on).with('2020-01-29').and_return(['expense_1', 'expense_2'])
        end

        it 'returns the expense records as JSON' do
          get '/expenses/2020-01-29'
          expenses = JSON.parse(last_response.body)

          expect(expenses).to eq(['expense_1', 'expense_2'])
        end

        it 'responds with a status code 200' do
          get '/expenses/2020-01-29'
          expect(last_response.status).to eq(200)
        end
      end

      context 'when no expenses exist on the given date' do
        before do
          allow(ledger).to receive(:expenses_on).with('2020-01-29').and_return([])
        end

        it 'returns sn empty array as JSON' do
          get '/expenses/2020-01-29'
          expenses = JSON.parse(last_response.body)

          expect(expenses).to eq([])
        end

        it 'responds with a status code 200' do
          get '/expenses/2020-01-29'
          expect(last_response.status).to eq(200)
        end
      end
    end

    describe 'POST /expenses' do
      context 'when the expense is sucessfully recorded' do
        before do
          # when the caller (API) invokes `record`, the double will return a new RecordResult instance indicating success
          allow(ledger).to receive(:record).with(expense).and_return(RecordResult.new(true, 123, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)
          expect(response).to include('expense_id' => 123)
        end

        it 'responds with a status code 200' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end
      end

      context 'when the expense fails validation' do
        before do
          allow(ledger).to receive(:record).with(expense).and_return(RecordResult.new(false, 123, 'Expense Incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)
          expect(response).to include('error' => 'Expense Incomplete')
        end

        it 'responds with a status code 422 (unprocessable entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end
  end
end
