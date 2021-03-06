# Rails::Plantuml::Generator
This gem Genrates a plantuml diagramm from your rails models for easy viewing.

## Usage
Run `rake plantuml:generate` to generate a plantuml diagramm of your models. The 
diagramm will be saved as `diagramm.pu`

You may pass a regex as argument to only include classes that match the given regex.

For example if you only want the models that have a name/module that starts with "U" you would run with:
```ruby
rake plantuml:generate[U*]
```

## Installation
Add this line to your application's Gemfile:

```ruby
group :development do
  gem 'rails-plantuml-generator', git: 'https://github.com/HappyKadaver/rails-plantuml-generator'
end
```

And then execute:
```bash
$ bundle
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
