steep-check:
	bundle exec steep check

steep-validate:
	bundle exec steep validate

rbs-inline:
	bundle exec rbs-inline --output app

rbs-inline-loop:
	bundle exec rbs-inline --output app --watch

# Gerar tipos para rails automaticamente, incluindo os tipos para os arquivos de modelo, controladores, etc.
rbs-rails-all:
	rake rbs_rails:all

# Gerar os tipos para as gems
rbs-collection-install:
	bundle exec rbs collection install
