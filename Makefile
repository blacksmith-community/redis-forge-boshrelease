.PHONY: test

# Renders the job templates and checks them. Needs the bosh-template and
# rspec gems.
test:
	ruby -e 'require "rspec/core"; exit RSpec::Core::Runner.run(["spec"])'
