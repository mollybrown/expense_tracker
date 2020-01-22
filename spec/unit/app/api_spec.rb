require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  # Use value objects at layer boundaries (https://www.destroyallsoftware.com/talks/boundaries)
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    # Create stand-in for instance of ExpenseTracker::Ledger class
    let(:ledger) { instance_double('ExpenseTracker::API::Ledger') }

    describe 'POST /expenses' do
      context 'when the expense is sucessfully recorded' do
        let(:expense) { expense = { 'some' => 'data' } }

        before do
          # `allow` is a rspec-mock behavior that configures the behavior of the test double
          # when the caller (API) invokes `record`, the double will return a new RecordResult instance indicating success
          allow(ledger).to receive(:record).with(expense).and_return(RecordResult.new(true, 123, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)

          response = JSON.parse(last_response.body)
          expect(response).to include('expense_id' => 123)
        end

        it 'responds with a status code 200' do
          post '/expenses', JSON.generate(expense)

          expect(last_response.status).to eq(200)
        end
      end

      context 'when the expense fails validation' do
        it 'returns an error message'
        it 'responds with a status code 422 (unprocessable entity)'
      end
    end
  end
end
