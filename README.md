# Techinform

Collection of console tools, useful for everyday tasks in Techinform Soft company (https://techinform.dev).

* All backups stored at /backups/local directory.
* All backup sync goes to /backups/< server name > directory.

## Installation

Install gem yourself as:

    $ gem install techinform
    
## Requirements

    apt install gpg2 pv mysqldump bzip2 rsync
    
* mysqldump - for mysql database dumps
* gpg2 - backup encryption support
* bzip2 - backup compression support (prefer lbzip2 if installed)
* rsync - syncing backups
    
## Configuration

All configuration is done via environment variables

Available variables:

    DEBUG=true                      # Print debug information on commands run
    GPGKEY=< email | key id >       # Enables encryption and encrypt with specific public key via gpg2. gpg2 should be installed
    DBUSER=root                       # User for database access
    PASSWORD=password               # Password for database access

## Usage

Available commands:

    $ techinform help [COMMAND]                      # Describe available commands or one specific command
    $ techinform restore [type] [filename] [dbname]  # Restore database from backup

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alexey-chernikov/techinform. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Techinform project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/techinform/blob/master/CODE_OF_CONDUCT.md).
