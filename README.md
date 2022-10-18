# README

* Ruby version
2.5.3

* Steps to run test in macOS
```bash
rbenv install 2.5.3
gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"
brew install postgresql
bundle install --without production
rails db:setup
rails test
```


