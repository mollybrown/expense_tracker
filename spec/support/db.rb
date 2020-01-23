# RSpec convention is to put "partially shared" code in spec/support
# defines a suite-level before hook
# runs once: after all the specs have been loaded but before the first one runs
RSpec.configure do |c|
  c.before(:suite) do
    Sequel.extension :migration
    Sequel::Migrator.run(DB, 'db/migrations') # run all migrations
    DB[:expenses].truncate # drop all test data from expenses table
  end

end
