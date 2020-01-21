require_relative '../../../app/api'

module ExpenseTracker
  RSpec.describe API do
    describe 'POST /expenses' do
      context 'when the expense is sucessfully recorded' do
        it 'returns the expense id'
        it 'responds with a status code 200'
      end
    end
  end
