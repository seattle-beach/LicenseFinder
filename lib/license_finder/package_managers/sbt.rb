module LicenseFinder
  class Sbt < PackageManager
    def initialize(options={})
      super
      @command = options[:sbt_command] || Sbt::package_management_command
    end

    def current_packages
          # ["The Apache License, Version 2.0","io.aeron","aeron-driver","1.2.5"]
      sbt_output.map do |license_text, package_info, name , version|
        SbtPackage.new(
          " " + name,
          " " + version,
          spec_licenses: [license_text],
          logger: logger
        )
      end
    end

    def self.package_management_command
      "sbt"
    end

    private

    def package_path
      project_path.join("build.sbt")
    end

    # Filter output to only the license entries.
    def filter_to_license_blocks(output)
      output.each_line.map do |line|
        line.chomp!
        line.sub!('[info] ','')
        if ['[success]', 'Updating', 'Loading', 'Resolving','Done','Set'].any?{ |f| line.start_with?(f) }
          ""
        else
          line
        end
      end
    end

    def sbt_output
      command = "#{@command} -no-colors dependencyLicenseInfo"
      output, success = Dir.chdir(project_path) { capture(command) }
      raise "Command '#{command}' failed to execute: #{output}" unless success

      license_groups = filter_to_license_blocks(output).chunk do |line|
        /\A\s*\z/ !~ line || nil
      end
      puts license_groups.join("\n")
      exit(0)
      deps = []
      license_groups.each do |_, license_group|
        puts "FAIL! #{license_group}" if license_group.length < 2
        license, *dependencies = *license_group
        dependencies.each do |d|
          d.strip!
          # ["The Apache License, Version 2.0","io.aeron","aeron-driver","1.2.5"]
          package_info, name, version = d.split(":")
          puts "WARNING: #{d}" if name.nil? || version.nil?
          deps << [license, package_info, name, version]
        end
      end

      puts "WARNING! #{license_text} #{package_info} #{version}" if name.nil? || version.nil?
      deps
    end
  end
end
