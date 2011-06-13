module FamilyTree

  class PersonDB

    def self.create(opts)
      case opts[:type]
      when :pstore
        PStorePersonDB.new(opts)
      when :postgres
        PostgresPersonDB.new(opts)
      else
        raise "Bad PersonDB type: #{type}"
      end
    end

  end

end
