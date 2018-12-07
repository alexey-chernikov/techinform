require 'thor'
require_relative '../../lib/backup/mysql_backup'
require_relative '../../lib/backup/postgre_backup'

module Techinform
  class BackupCommand < Thor
    desc 'mysql [dbname | dbname1,dbname2,... | all] ', 'Backup mysql database/databases, or all databases in separate files'
    def mysql(dbnames)
      (dbnames == 'all' ? mysql_list : dbnames.split(',')).each do |db|
        MysqlBackup.new(user: ENV['USER'], database: db, password: ENV['PASSWORD'], encrypt: encrypt?).run
      end
    end

    desc 'pg_list', 'List of postgres databases'
    def mysql_list
      dbs = MysqlBackup.new(user: ENV['USER'], password: ENV['PASSWORD'], encrypt: encrypt?).db_list
      puts "Available mysql databases: #{dbs.join(', ')}"
      dbs
    end

    desc 'pg [dbname | dbname1,dbname2,... | all]', 'Backup postgres database/databases or all databases in separate files'
    def pg(dbnames)
      (dbnames == 'all' ? pg_list : dbnames.split(',')).each do |db|
        PostgreBackup.new(user: ENV['USER'], database: db, password: ENV['PASSWORD'], encrypt: encrypt?).run
      end
    end

    desc 'pg_list', 'List of postgres databases'
    def pg_list
      dbs = PostgreBackup.new(user: ENV['USER'], password: ENV['PASSWORD'], encrypt: encrypt?).db_list
      puts "Available postgres databases: #{dbs.join(', ')}"
      dbs
    end

    desc 'etc', 'Backup of /etc folder'
    def etc
      require_relative '../../lib/backup/etc_backup'
      EtcBackup.new.run
    end

    private

    def encrypt?
      !ENV['GPGKEY'].nil?
    end
  end
end