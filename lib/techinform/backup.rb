require 'thor'
require_relative '../../lib/backup/mysql_backup'
require_relative '../../lib/backup/postgre_backup'
require_relative 'defaults'
require 'tempfile'

module Techinform
  class BackupCommand < Thor
    desc 'mysql [dbname | dbname1,dbname2,... | all] ', 'Backup mysql database/databases, or all databases in separate files'
    def mysql(dbnames)
      (dbnames == 'all' ? mysql_list : dbnames.split(',')).each do |db|
        MysqlBackup.new(database: db).run
      end
    end

    desc 'pg_list', 'List of postgres databases'
    def mysql_list
      dbs = MysqlBackup.new.db_list
      puts "Available mysql databases: #{dbs.join(', ')}"
      dbs
    end

    desc 'pg [dbname | dbname1,dbname2,... | all]', 'Backup postgres database/databases or all databases in separate files'
    def pg(dbnames)
      (dbnames == 'all' ? pg_list : dbnames.split(',')).each do |db|
        PostgreBackup.new(database: db).run
      end
    end

    desc 'pg_list', 'List of postgres databases'
    def pg_list
      dbs = PostgreBackup.new.db_list
      puts "Available postgres databases: #{dbs.join(', ')}"
      dbs
    end

    desc 'files [path]', 'Files backup'
    def files(files_backup='/etc')
      require_relative '../../lib/backup/files_backup'
      FilesBackup.new(files_backup).run
    end

    desc 'etc', 'Backup of /etc folder'
    def etc
      require_relative '../../lib/backup/files_backup'
      FilesBackup.new('/etc').run
    end

    desc 'sync [server] [type] [ipaddr | dnsname]', 'Sync backups from remote server'
    option :delete, type: :boolean, default: false, desc: 'Mirror files (delete non-existent) on sync'
    def sync(server, type, ipaddr)
      location = Techinform.backups_syncing_location(server, type)
      `mkdir -p #{location}`
      system("rsync -avz #{'--delete' if options[:delete]} #{"--exclude-from=#{"#{File.dirname(__FILE__)}/sync/rails_exclude_files"}" if type == 'rails'} backup@#{ipaddr}::#{type} #{location}")
    end
  end
end