require_relative 'db_backup'

class MysqlBackup < DbBackup
  def print_info
    puts "Run mysql backup on #{database} to #{filepath}..."
  end

  def backup_command
    "mysqldump -C #{"--password='#{password}'" if password} #{"-h #{host}" if host} #{"--user=#{user}" if user} #{database}"
  end

  def db_list
    @db_list ||= `mysql #{"--password='#{password}'" if password} #{"-h #{host}" if host} #{"--user=#{user}" if user} -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`.split
  end
end

