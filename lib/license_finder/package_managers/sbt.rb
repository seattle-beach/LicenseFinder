module LicenseFinder
  class Sbt < PackageManager
    def initialize(options={})
      super
      @command = options[:sbt_command] || Sbt::package_management_command
    end

    def current_packages
      report_csv = Dir.glob(File.join('target','license-reports') + '/*csv').first
      CSV.read(report_csv, headers: true).map do |row|
        _package_info, package_name, version = row['Dependency'].split(' # ')
          SbtPackage.new(
              package_name,
              version,
            spec_licenses: [row['Category'], row['License']],
            logger: logger
          )
      end
    end

    def self.package_management_command
      "sbt"
    end

    def package_path
      project_path.join('build.sbt')
    end

    private

    def run_sbt_license_report
      command = "#{@command} -no-colors dumpLicenseReport"
      output, success = Dir.chdir(project_path) { capture(command) }
      raise "Command '#{command}' failed to execute: #{output}" unless success
    end
  end
end
