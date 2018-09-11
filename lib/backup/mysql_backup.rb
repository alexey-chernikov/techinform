require_relative 'db_backup'

class MysqlBackup < DbBackup
  def run
    puts "Run mysql backup on #{database} to #{filepath}..."
    command = "mysqldump -C #{"--password=#{password}" if password} #{"-h #{host}" if host} #{"--user=#{user}" if user} #{database}"
    command += " | bzip2" if compress?
    command += " > #{filepath}"
    output = `#{command}`
    puts output unless output.empty?
  end

  def db_list
    @db_list ||= `mysql #{"--password=#{password}" if password} #{"-h #{host}" if host} #{"--user=#{user}" if user} -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`.split
  end
end

