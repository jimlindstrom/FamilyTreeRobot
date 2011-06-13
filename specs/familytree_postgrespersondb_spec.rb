# familytree_postgrespersondb_spec.rb

require './mediawiki/page'
require './familytree/person'
require './familytree/persondb'

require './specs/familytree_persondb_spec'

describe FamilyTree::PStorePersonDB do

  let(:create_persondb) {

    # Read configuration
    config      = YAML.load_file 'config/robot_config_pstore.yml'
    #@mw_opts    = config["mw_opts"]
    @db_opts    = config["db_opts"]
    #@robot_acct = config["robot_acct"]

    @person_db = FamilyTree::PersonDB.create(@db_opts)
    @person_db.reset
  }

  it_should_behave_like 'FamilyTree::PersonDB'

end
  
