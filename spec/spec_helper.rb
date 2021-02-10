require "climate_control"
require "webmock/rspec"
require "rake"
require "active_support/testing/time_helpers"
require "ask_export"
require "smart_survey"
require "factory_bot"

Dir["#{__dir__}/support/**/*.rb"].sort.each { |f| require f }
WebMock.disable_net_connect!
Rake.application.load_rakefile

RSpec.configure do |config|
  include ActiveSupport::Testing::TimeHelpers
  include AwsS3Helper
  include GoogleCloudHelper
  include GoogleDriveHelper
  include SmartSurveyHelper

  config.disable_monkey_patching!

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
