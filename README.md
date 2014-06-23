# Backlog::Cli

Backlog Command Line Interface

## Installation

Add this line to your application's Gemfile:

    gem 'backlog-cli'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install backlog-cli

## Setting File(required)

```yaml:$HOME/.backlogrc

default:
  space: toyama0919
  user: toyama0919
  password: hogehoge
  assigner_id: 4604

company:
  space: hoge
  user: toyama-h
  password: hogehoge
  assigner_id: 19981

```

## Usage

  ### use default profile
  ```bash
  backlog-cli -l PROJ
  ```

  ### use other profile
  ```bash
  backlog-cli -l PROJ --profile company
  ```

  ### help
  ```bash
  backlog-cli -l PROJ --profile company
  ```


## Contributing

1. Fork it ( http://github.com/<my-github-username>/backlog-cli/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
