require 'techinform/version'
require 'techinform/projects'
require_relative 'techinform/backup'
require 'thor'
require 'bzip2_selector'


module Techinform
  class CLI < Thor
    desc 'restore [type] [absolute_filename or database to select file] [dbname]', 'Restore database from backup; if no absolute filename given, will present select menu to choose file'
    def restore(type, filename, dbname = nil, just_decrypt = false)
      require 'highline'
      dbname = filename if dbname.nil?
      if !File.exist?(filename)
        cli = HighLine.new
        path = type == 'pg' ? PostgreBackup.new(database: filename).restore_path : MysqlBackup.new(database: filename).restore_path
        filename = cli.choose(*Dir["#{path}/*"].sort - %w[. ..])
      end
      encrypted = filename.split('.').last == 'gpg'
      if type == 'pg'
        if encrypted && just_decrypt
          puts "Decrypting postgres backup of #{filename}..."
          `pv --wait #{filename} | gpg2 --decrypt  | #{bzip2} > #{File.basename(filename, '.*') + '.bz2'}`
        elsif encrypted
          puts "Restoring postgres backup to database #{dbname}..."
          `pv --wait #{filename} | gpg2 --decrypt | psql #{dbname} > /dev/null`
        else
          `pv --wait #{filename} | #{bunzip2} | psql #{dbname} > /dev/null`
        end
      else
        if encrypted && just_decrypt
          puts "Decrypting mysql backup of #{filename}..."
          `pv --wait #{filename} | gpg2 --decrypt | #{bzip2} > #{File.basename(filename, '.*') + '.bz2'}`
        elsif encrypted
          puts "Restoring mysql backup to database #{dbname}..."
          puts "pv --wait #{filename} | gpg2 --decrypt | mysql #{"-u#{ENV['DBUSER']}" if !ENV['DBUSER'].nil?} #{"-p#{ENV['PASSWORD']}" if !ENV['PASSWORD'].nil?} #{dbname}"
          `pv --wait #{filename} | gpg2 --decrypt | mysql #{"-u#{ENV['DBUSER']}" if !ENV['DBUSER'].nil?} #{"-p#{ENV['PASSWORD']}" if !ENV['PASSWORD'].nil?} #{dbname}`
        else
          `pv --wait #{filename} | #{bunzip2} | mysql #{"-u#{ENV['DBUSER']}" if !ENV['DBUSER'].nil?} #{"-p#{ENV['PASSWORD']}" if !ENV['PASSWORD'].nil?} #{dbname}`
        end
      end
    end

    desc 'decrypt [type] [absolute_filename or database to select file]', 'Decrypt file from backup; if no absolute filename given, will present select menu to choose file'
    def decrypt(type, filename)
      puts "lbzip2 is not found. Single-threaded bzip2 will be used. Consider installing lbzip2" if bzip2 == 'bzip2'
      restore(type, filename, nil, true)
    end

    desc 'deploy [project]', 'Deploy specific project'
    def deploy(project)
      `cd ~/projects/#{project} && git pull origin master && bundle install && cap production deploy`
    end

    desc 'projects', 'Projects'
    subcommand :projects, Techinform::Projects
    desc 'backup', 'Backup'
    subcommand :backup, Techinform::BackupCommand
    desc "clean [prefix]", 'Clean old backup files (default prefix: local)'
    option :delete, type: :boolean, desc: 'Actually delete files'
    option :quiet, type: :boolean, desc: 'Do not ask permission on deletion'
    def clean(prefix = 'local')
      puts Backup.new(dry_run: !options[:delete], quiet: options[:quiet]).clean_files(prefix)
    end
  end
end

#MysqlBackup.new(user: 'root', database: 'lakor').run
#PostgreBackup.new(user: 'alex', database: 'carmen').run
