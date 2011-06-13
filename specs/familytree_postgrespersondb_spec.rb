# familytree_postgrespersondb_spec.rb

require './mediawiki/page'
require './familytree/person'
require './familytree/persondb'

require './specs/familytree_persondb_spec'

describe FamilyTree::PStorePersonDB do

  let(:create_persondb) {
    db_type = :postgres
    db_opts = {:host => 'localhost',
               :port => nil,
               :options => nil,
               :tty => nil,
               :dbname => 'people_rspec',
               :user => 'jim',
               :pass => 'password'}
    @person_db = FamilyTree::PersonDB.create(db_type, db_opts)
    @person_db.reset
  }

  it_should_behave_like 'FamilyTree::PersonDB'

end
  
