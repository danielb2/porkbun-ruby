# Porkbun

Reference: https://porkbun.com/api/json/v3/documentation

## Installation

`gem install porkbun`

## Usage

```ruby
Porkbun.API_KEY = 'YOUR_API_KEY'
Porkbun.SECRET_API_KEY = 'YOUR_SECRET_API_KEY'
record = Porkbun::DNS.create(name: 'test',
type: 'A',
content: '1.1.1.1',
ttl: 300
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danielb2/porkbun.
