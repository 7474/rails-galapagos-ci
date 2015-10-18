# RailsGalapagosCi

Ruby on Rails で日本的なガラパゴスなCIを行うためのユーティリティ(を作っていく予定)です。

## Installation

Add this line to your "Rails" application's Gemfile:

```ruby
# group :development do
gem 'rails-galapagos-ci'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails-galapagos-ci

ER図出力を行う場合は、以下の依存関係をインストールしてください。

    $ sudo yum install graphviz
    $ sudo yum install ipa-*-fonts

## Usage

### gci:erd Task

[MigrationComments](https://github.com/pinnymz/migration_comments) で付与したコメントを論理名として適用したER図を出力します。

[Rails ERD](https://github.com/voormedia/rails-erd) をラップしたものですので、出力オプションも同様です。

    $  rake gci:erd
    $  rake gci:erd filename=hogehoge-erd
    $  rake gci:erd filename=hogehoge-erd filetype=svg

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rails-galapagos-ci. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Thanks

* [Rails ERD](https://github.com/voormedia/rails-erd)
* [MigrationComments](https://github.com/pinnymz/migration_comments)
* [Graphviz](http://www.graphviz.org/)
