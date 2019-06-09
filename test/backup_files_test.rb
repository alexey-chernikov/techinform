require "test_helper"
require_relative '../lib/backup/files_backup'

class BackupFilesTest < Minitest::Test
  def test_backup_type_filename
    assert_equal FilesBackup.new('/etc').backup_type_filename, 'etc'
    assert_equal FilesBackup.new('/opt/test').backup_type_filename, 'opt_test'
  end

  def test_backup_type
    assert_equal FilesBackup.new('/etc').backup_type, 'files'
  end

  def test_filepath
    assert_match /\/backups\/local\/files\/etc\/etc-/, FilesBackup.new('/etc').filepath
  end
end
