# Jekyll::Popolo

Populate Jekyll Collections dynamically from Popolo JSON.

## Installation

Add this line to your application's Gemfile:

```ruby
group :jekyll_plugins do
  gem 'jekyll-popolo'
end
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-popolo

## Usage

You need to explicitly specify what data you want in each collection. Put the following in `_plugins/popolo.rb`:

```ruby
Jekyll::Popolo.register(:senate, File.read('australia-senate-popolo.json'))

Jekyll::Popolo.process(:senate) do |popolo|
  # `popolo` is a Hash with string keys
  {
    mps: popolo['people'],
    areas: popolo['areas'],
    parties: popolo['organizations'].select { |o| o['classification'] == 'party' },
  }
end
```

This configuration will create 3 Jekyll Collections: `_mps`, `_areas` and `_parties`. These won't exist on disk, they are just "virtual" collections.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/theyworkforyou/jekyll-popolo.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
