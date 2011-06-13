# familytree_pstorepersondb_spec.rb

require './mediawiki/page'
require './familytree/person'
require './familytree/persondb'

require './specs/familytree_persondb_spec'

describe FamilyTree::PStorePersonDB do

  let(:create_persondb) {
    db_type = :pstore
    db_opts = {:filename => "person_db.pstore"}
    @person_db = FamilyTree::PersonDB.create(db_type, db_opts)
    @person_db.reset
  }

  it_should_behave_like 'FamilyTree::PersonDB'

end

