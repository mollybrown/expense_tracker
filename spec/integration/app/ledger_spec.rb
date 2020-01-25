require_relative '../../../app/ledger'
require 'pry'

module ExpenseTracker
  RSpec.describe Ledger, :aggregate_failures, :db do
    let(:ledger) { Ledger.new }
    let(:expense) do
      {
        'payee' => 'Starbucks',
        'amount' => '5.75',
        'date' => '2020-01-29'
      }
    end

    describe '#record' do
      context 'with a valid expense' do
        it 'records the expense' do
          result = ledger.record(expense)
          # binding.pry
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

      context 'invalid expense' do
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

        context 'when the expense is missing an amount' do
          it 'rejects the expense as invalid' do
            expense.delete('amount')

            result = ledger.record(expense)

            expect(result).not_to be_success
            expect(result.expense_id).to eq(nil)
            expect(result.error_message).to include('`amount` is required')
            expect(DB[:expenses].count).to eq(0)
          end
        end

        context 'when the expense is missing a date' do
          it 'rejects the expense as invalid' do
            expense.delete('date')

            result = ledger.record(expense)

            expect(result).not_to be_success
            expect(result.expense_id).to eq(nil)
            expect(result.error_message).to include('`date` is required')
            expect(DB[:expenses].count).to eq(0)
          end
        end

        context 'when the expnse is missing multiple keys' do
          it 'rejects the expense as invalid' do
            expense.delete('payee')
            expense.delete('date')

            result = ledger.record(expense)

            expect(result).not_to be_success
            expect(result.expense_id).to eq(nil)
            expect(result.error_message).to eq("Invalid Expense: [\"`payee` is required\", \"`date` is required\"]")
            expect(DB[:expenses].count).to eq(0)
          end
        end
      end


    end

    describe '#expenses_on' do
      it 'returns all expenses for the provided date' do
        result_1 = ledger.record(expense.merge('date' => '2020-01-20'))
        result_2 = ledger.record(expense.merge('date' => '2020-01-29'))
        result_3 = ledger.record(expense.merge('date' => '2020-01-29'))

        expect(ledger.expenses_on('2020-01-29')).to contain_exactly(
          a_hash_including(id: result_2.expense_id),
          a_hash_including(id: result_3.expense_id)
        )
      end
    end
  end
end
