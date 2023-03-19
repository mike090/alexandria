start:
	bundle exec rails s

setup:
	bundle install

lint:
	bundle exec rubocop

check: lint
