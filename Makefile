rbs_infer_all:
	bundle exec rbs_infer app/ lib/ --output

rbs_collection_update:
	rbs collection update

rbs_rails_generator:
	bundle exec rake rbs_rails:all

rbs_infer_enumerize:
	bundle exec rake rbs_infer:enumerize:all

rbs_infer_carrierwave:
	bundle exec rake rbs_infer:carrierwave:all

rbs_infer_rails_custom:
	bundle exec rake rbs_infer:rails_custom:all

rbs_infer_erb:
	bundle exec rake rbs_infer:erb:all

rbs_generators_all:
	make rbs_rails_generator
	make rbs_infer_rails_custom
	make rbs_infer_enumerize
	make rbs_infer_carrierwave
	make rbs_infer_erb
	make rbs_infer_all
