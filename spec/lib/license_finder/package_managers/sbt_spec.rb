require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Sbt do
    it_behaves_like "a PackageManager"



    context 'Running in an sbt project' do
    include FakeFS::SpecHelpers
    let(:root) { "/fake-scala-project" }
    let(:license_report_path){ File.join('target','license-reports') }
    let(:sbt) { Sbt.new project_path: Pathname.new(root) }
    let(:sbt_license_report_file_fixture) do
      FakeFS.without do
        File.read fixture_path File.join('sbt', 'license-report.csv')
      end
    end
    let(:sbt_build_file_fixture) do
      FakeFS.without do
        File.read fixture_path File.join('all_pms', 'build.sbt')
      end
    end

      before do
        FakeFS do
          FileUtils.mkdir_p(license_report_path)
          File.write(File.join(license_report_path, 'license-report.csv'), sbt_license_report_file_fixture)

          FileUtils.mkdir_p(root)
          File.write(File.join(root, "build.sbt"), sbt_build_file_fixture)

        end
      end

      describe '.current_packages' do
        it 'fetches data from sbt' do
          expect(sbt.current_packages.size).to eq 166
        end
      end
    end
  end
end
