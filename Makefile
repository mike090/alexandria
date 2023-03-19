start:
	bundle exec rails s

setup:
	bundle install

lint:
	bundle exec rubocop

test:
	bundle exec rspec

check: lint test

.PHONY: test
