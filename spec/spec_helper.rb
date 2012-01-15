SPEC_PATH = File.expand_path(File.dirname(__FILE__))
$:.unshift File.expand_path('../lib', SPEC_PATH) # ensure local lib/ is loaded

require "bundler/setup"
require "rubygems"
require "couchrest_casted"

FIXTURE_PATH = File.expand_path('fixtures', SPEC_PATH)

COUCHHOST = "http://127.0.0.1:5984"
TESTDB    = 'couchrest_casted-test'

TEST_SERVER = CouchRest.new(COUCHHOST)
TEST_SERVER.default_database = TESTDB
DB = TEST_SERVER.database(TESTDB)


def reset_test_db!
  DB.recreate! rescue nil
  DB
end


# set up the before and after testing hooks
RSpec.configure do |config|
  # start with a fresh database
  config.before(:all) do
    reset_test_db!
  end

  # delete all testing databases
  config.after(:all) do
    test_dbs = TEST_SERVER.databases.select { |db| db =~ /^#{TESTDB}/ }
    test_dbs.each do |db|
      TEST_SERVER.database(db).delete! rescue nil
    end
  end
end

