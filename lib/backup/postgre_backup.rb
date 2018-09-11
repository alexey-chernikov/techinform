require_relative 'db_backup'

class PostgreBackup < DbBackup
  def run
    if database != 'all'
      dbs = [database]
    else
      dbs = db_list
      puts "Available postgres databases: #{dbs.join(', ')}"
    end
    dbs.each do |database|
      puts "Run postgre backup on #{database}..."
      command = "#{"PGPASSWORD=#{password}" if password} pg_dump --clean --if-exists --no-owner #{"--host=#{host}" if host} #{"--username=#{user}" if user} #{database}"
      command += " | bzip2" if compress?
      command += " > #{filepath}"
      output = `#{command}`
      puts output unless output.empty?
    end
  end

  def db_list
    @dbs ||= `#{"PGPASSWORD=#{password}" if password} psql #{"--host=#{host}" if host} #{"--username=#{user}" if user} -t -c 'SELECT datname FROM pg_database WHERE datistemplate = false;`.split.compact
  end
end
