require 'thor'
require_relative '../../lib/backup/mysql_backup'
require_relative '../../lib/backup/postgre_backup'

module Techinform
  class BackupCommand < Thor
    desc 'mysql [dbname | dbname1,dbname2,... | all] ', 'Backup mysql database/databases, or all databases in separate files'
    def mysql(dbnames)
      dbnames.split(',').each do |db|
        MysqlBackup.new(user: ENV['USER'], database: db, password: ENV['PASSWORD']).run
      end
    end

    desc 'pg [dbname | dbname1,dbname2,... | all]', 'Backup postgres database/databases or all databases in separate files'
    def pg(dbnames)
      dbnames.split(',').each do |db|
        PostgreBackup.new(user: ENV['USER'], database: db, password: ENV['PASSWORD']).run
      end
    end
  end
end