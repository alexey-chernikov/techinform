require 'techinform/version'
require 'techinform/projects'
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

    desc 'deploy [project]', 'Deploy specific project'
    def deploy(project)
      `cd ~/projects/#{project} && git pull origin master && bundle install && cap production deploy`
    end

    desc 'projects', 'Projects'
    subcommand :projects, Techinform::Projects
  end
end
