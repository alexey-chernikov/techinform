require 'techinform/version'
require 'techinform/projects'
require_relative 'techinform/backup'
require 'thor'

module Techinform
  class CLI < Thor
    desc 'restore [type] [absolute_filename or database to select file] [dbname]', 'Restore database from backup; if no absolute filename given, will present select menu to choose file'
    def restore(type, filename, dbname)
      require 'highline'
      if !File.exist?(filename)
        cli = HighLine.new
        path = type == 'pg' ? PostgreBackup.new(database: filename).path : MysqlBackup.new(database: filename)
        filename = "#{path}/#{cli.choose(*Dir.entries(path) - %w[. ..])}"
      end
      encrypted = filename.split('.').last == 'gpg'
      if type == 'pg'
        puts "Restoring postgres backup to database #{dbname}..."
        if encrypted
          `gpg2 --decrypt #{filename} | pv --wait | psql #{dbname} > /dev/null`
        else
          `tar -xOf #{filename} | bunzip2 | pv | psql #{dbname} > /dev/null`
        end
      else
        puts "Restoring mysql backup to database #{dbname}..."
        if encrypted
          `gpg2 --decrypt #{filename} | pv --wait | mysql #{"-u#{ENV['USER']}" if !ENV['USER'].nil?} #{"-p#{ENV['PASSWORD']}" if !ENV['PASSWORD'].nil?} #{dbname}`
        else
          `tar -xOf #{filename} | bunzip2 | pv | mysql #{"-u#{ENV['USER']}" if !ENV['USER'].nil?} #{"-p#{ENV['PASSWORD']}" if !ENV['PASSWORD'].nil?} #{dbname}`
        end
      end
    end

    desc 'deploy [project]', 'Deploy specific project'
    def deploy(project)
      `cd ~/projects/#{project} && git pull origin master && bundle install && cap production deploy`
    end

    desc 'projects', 'Projects'
    subcommand :projects, Techinform::Projects
    desc 'backup', 'Backup'
    subcommand :backup, Techinform::BackupCommand
  end
end

#MysqlBackup.new(user: 'root', database: 'lakor').run
#PostgreBackup.new(user: 'alex', database: 'carmen').run
