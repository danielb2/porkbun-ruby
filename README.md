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
domain = Porkbun.new('domain.org')

domain.records.each { |record| puts record.to_s }

record = domain.create_record('test',
  type: 'A',
  content: '1.1.1.1',
  ttl: 300
)
record.update(content: '8.8.8.8')
record.delete

```

## API

### `Porkbun.ping`

Make sure your keys are good.

## Classes

### `Porkbun::Domain`

#### class methods

- `all` - returns an array of `Porkbun::Domain` objects for each domain in the account.
- `create_record(hostname, options)` - returns a `Porkbun::Record` created from a full hostname.
- `get_record(hostname)` - returns one unambiguous `Porkbun::Record`.
- `import(file)` - returns an array of `Porkbun::Record` objects created from a zone file.
- `update_dynamic(hostname, ip)` - returns a hash describing the created or updated record.

```ruby
Porkbun::Domain.all.each { |domain| puts domain }
record = Porkbun::Domain.get_record('www.domain.org')
record.update(content: '8.8.8.8')
```

#### instance methods

`Porkbun.new('domain.org')` returns a `Porkbun::Domain` object.

- `records` - returns an array of `Porkbun::Record` objects for the domain.
- `get_record(name)` - returns one unambiguous `Porkbun::Record`; `name` can be relative or fully qualified.
- `create_record(name, options)` - returns a new `Porkbun::Record`.
- `delete_all_records` - returns an array of `Porkbun::Record` objects after deleting all non-NS records.
- `zone_file` - returns a string that can be passed to `import`.

```ruby
domain = Porkbun.new('domain.org')
record = domain.get_record('www')
record.update(content: '8.8.8.8')
record.delete

domain.delete_all_records
```

### `Porkbun::Record`

A `Porkbun::Record` represents one DNS record and owns its mutations.

#### instance methods

- `update(content:, ttl:)` - returns the updated `Porkbun::Record`.
- `delete` - returns the deleted `Porkbun::Record`.
- `to_s` - returns a string containing the BIND zone entry.

```ruby
record = domain.get_record('www')
puts record.to_s
record.update(ttl: 700)
record.delete
```


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
