# Load the Rails environment
require_relative "config/environment" unless %w[-h --help help -T list -v version].include?(ARGV.first)

# Ensure tasks exit with non-zero status if something goes wrong
class << Thor
    def exit_on_failure?
        true
    end
end
