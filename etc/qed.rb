#
# QED test coverage report using SimpleCov.
#
# Use `$properties.coverage_folder` to set directory in which to store
# coverage report this defaults to `log/coverage`.
#
QED.configure 'coverage' do
  dir = $properties.coverage_folder
  require 'simplecov'
  SimpleCov.command_name 'QED'
  SimpleCov.start do
    coverage_dir(dir || 'log/coverage')
    #add_group "Label", "lib/qed/directory"
  end
end

