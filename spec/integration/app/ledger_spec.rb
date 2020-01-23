require_relative '../../../app/ledger'
require_relative '../../../config/sequel'
require_relative '../../support/db'

module ExpenseTracker
  RSpec.describe Ledger, :aggregate_failures do
    let(:ledger) { Ledger.new }
    let(:expense) do
      {
        'payee' => 'Starbucks',
        'amount' => '5.75',
        'date' => '2020-01-29'
      }
    end

    describe 'record' do
      context 'with a valid expense' do
        it 'records the expense' do
          result = ledger.record(expense)

          expect(result).to be_success # checks if result.success? is true
          expect(DB[:expenses].all).to match([a_hash_including(
            # keeps test suite fast by minimizing DB setup and teamdown: two expectations in one example
            # expect one element array of hashes with certain keys and values
            id: result.expense_id,
            payee: 'Starbucks',
            amount: 5.75,
            date: Date.iso8601('2020-01-29')
            )]
          )
        end
      end

      context 'when the expense is missing a payee' do
        it 'rejects the expense as invalid' do
          expense.delete('payee')

          result = ledger.record(expense)

          expect(result).not_to be_success
          expect(result.expense_id).to eq(nil)
          expect(result.error_message).to include('`payee` is required')
          expect(DB[:expenses].count).to eq(0)
        end
      end
    end
  end
end