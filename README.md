# Porkbun

Reference: https://porkbun.com/api/json/v3/documentation

This is currently only a partial implementation to suit my own needs. If you
need a specific call to be implemented, let me know, or submit a PR

## Installation

`gem install porkbun`

## Usage

```ruby
ENV['PORKBUN_API_KEY'] = 'YOUR_API_KEY'
ENV['PORKBUN_SECRET_API_KEY'] = 'YOUR_SECRET_API_KEY'
record = Porkbun::DNS.create(name: 'test',
  type: 'A',
  content: '1.1.1.1',
  ttl: 300
)
```

## API

### `Porkbun.ping`

Make sure your keys are good.

### `Porkbun::DNS.list(domain, id)`

List all or a specific record for a domain

### `Porkbun::DNS.create(options)`

Create record for a domain

options:
- `name` - name of record. example `www`
- `type` - record type. example: CNAME
- `content` - content of record. example '1.1.1.1',
- `ttl` - time to live. example: 600. porkbun seems to have this as a minimum
- `prio` - record priority. mainly for MX records. example 10.

returns instance of DNS which can be used to delete

### Record helpers

- `Porkbun::DNS.create_record(record, options)` - Create a record from a full hostname.
- `Porkbun::DNS.records_for(record, id = nil)` - List records for a domain or hostname.
- `Porkbun::DNS.find_record(record)` - Find one unambiguous record by hostname.
- `Porkbun::DNS.update_record(record, options)` - Update content or TTL and save the record.
- `Porkbun::DNS.delete_record(record)` - Delete one unambiguous record by hostname.
- `Porkbun::DNS.delete_all(domain, id = '')` - Delete all non-NS records for a domain.

## CLI

The gem also comes with a CLI

    $ porkbun
    Commands:
      porkbun add RECORD --content=CONTENT --type=TYPE                         # Add a new record
      porkbun update RECORD [--content=CONTENT] [--ttl=TTL]                    # Update a record (alias: up)
      porkbun rm_rf DOMAIN                                                      # deletes all records for a domain. this is destructive. use with caution
      porkbun rm RECORD                                                       # Delete one record for a hostname
      porkbun dyndns HOSTNAME [IP]                                              # Update a dynamic dns record. example: porkbun dyndns home.example.com
      porkbun env                                                               # Print environment variables
      porkbun help [COMMAND]                                                    # Describe available commands or one specific command
      porkbun import FILE                                                       # Import BIND zone file
      porkbun ls [DOMAIN] [ID]                                                  # List all domains or records for a domain


be sure to set the environmental variables for it to work

export PORKBUN_API_KEY = YOUR_API_KEY
export PORKBUN_SECRET_API_KEY = YOUR_SECRET_API_KEY

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danielb2/porkbun-ruby.
