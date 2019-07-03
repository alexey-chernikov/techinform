require 'techinform/version'
require 'techinform/projects'
require_relative 'techinform/backup'
require 'thor'

module Techinform
  class CLI < Thor
    desc 'restore [type] [absolute_filename or database to select file] [dbname]', 'Restore database from backup; if no absolute filename given, will present select menu to choose file'
    def restore(type, filename, dbname, just_decrypt = false)
      require 'highline'
      if !File.exist?(filename)
        cli = HighLine.new
        path = type == 'pg' ? PostgreBackup.new(database: filename).restore_path : MysqlBackup.new(database: filename).restore_path
        filename = cli.choose(*Dir["#{path}/*"].sort - %w[. ..])
      end
      encrypted = filename.split('.').last == 'gpg'
      if type == 'pg'
        puts "Restoring postgres backup to database #{dbname}..."
        if encrypted && just_decrypt
          `gpg2 --decrypt #{filename} | pv --wait > #{File.basename(filename, '.*')}`
        elsif encrypted
          `gpg2 --decrypt #{filename} | pv --wait | psql #{dbname} > /dev/null`
        else
          `tar -xOf #{filename} | bunzip2 | pv | psql #{dbname} > /dev/null`
        end
      else
        puts "Restoring mysql backup to database #{dbname}..."
        if encrypted && just_decrypt
          `gpg2 --decrypt #{filename} | pv --wait > #{File.basename(filename, '.*')}`
        elsif encrypted
          `gpg2 --decrypt #{filename} | pv --wait | mysql #{"-u#{ENV['USER']}" if !ENV['USER'].nil?} #{"-p#{ENV['PASSWORD']}" if !ENV['PASSWORD'].nil?} #{dbname}`
        else
          `tar -xOf #{filename} | bunzip2 | pv | mysql #{"-u#{ENV['USER']}" if !ENV['USER'].nil?} #{"-p#{ENV['PASSWORD']}" if !ENV['PASSWORD'].nil?} #{dbname}`
        end
      end
    end

    desc 'decrypt [type] [absolute_filename or database to select file]', 'Decrypt file from backup; if no absolute filename given, will present select menu to choose file'
    def decrypt(type, filename)
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
