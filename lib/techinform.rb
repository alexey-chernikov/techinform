require 'techinform/version'
require 'thor'

module Techinform
  class CLI < Thor
    desc 'restore [type] [filename] [dbname]', 'Restore database from backup'
    def restore(type, filename, dbname)
      if type == 'pg'
        echo "Restoring postgres backup to database #{dbname}..."
        `tar -xOf #{filename} | gunzip | pv | psql $3 > /dev/null`
      else
        echo "Restoring mysql backup to database #{dbname}..."
        `tar -xOf #{filename} | gunzip | pv | mysql -uroot #{dbname}`
      end
    end
  end
end
