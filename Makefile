steep-check:
	bundle exec steep check

steep-validate:
	bundle exec steep validate

rbs-inline:
	bundle exec rbs-inline --output app

rbs-inline-loop:
	bundle exec rbs-inline --output app --watch
