require_relative 'db_backup'

class PostgreBackup < DbBackup
  def print_info
    puts "Run postgre backup on #{database} to #{filepath}..."
  end

  def backup_command
    "#{"PGPASSWORD=#{password}" if password} pg_dump --clean --if-exists --no-owner #{"--host=#{host}" if host} #{"--username=#{user}" if user} #{database}"
  end

  def db_list
    @db_list ||= (`#{"PGPASSWORD=#{password}" if password} psql #{"--host=#{host}" if host} #{"--username=#{user}" if user} -t -c 'SELECT datname FROM pg_database WHERE datistemplate = false;'`.split.compact - ['root'])
  end
end
