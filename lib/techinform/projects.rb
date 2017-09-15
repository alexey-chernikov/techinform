require 'thor'

module Techinform
  class Projects < Thor
    desc 'list', 'List all projects'
    def list
      # Display only directories
      puts `ls -F ~/projects/ | grep /`.gsub('/', '')
    end
  end
end