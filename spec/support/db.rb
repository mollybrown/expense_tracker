# RSpec convention is to put "partially shared" code in spec/support
# defines a suite-level before hook
# runs once: after all the specs have been loaded but before the first one runs
RSpec.configure do |c|
  c.before(:suite) do
    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'db/migrations') # run all migrations
    DB[:expenses].truncate # drop all test data from expenses table
  end

  c.around(:example, :db) do |example| # use :db metadata tag
    DB.transaction(rollback: :always) { example.run } # run each example requiring the DB w/i a transaction, then rollback
  end

end
