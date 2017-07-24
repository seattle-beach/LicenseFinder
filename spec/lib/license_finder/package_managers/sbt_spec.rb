require 'spec_helper'

module LicenseFinder
  describe Sbt do
    subject { Sbt.new(project_path: Pathname('/fake/path')) }

    it_behaves_like "a PackageManager"

    output = <<-CMDOUTPUT
[info] Loading global plugins from /Users/wesleymaldonado/.sbt/0.13/plugins
[info] Loading project definition from /Users/wesleymaldonado/ws/scastie/project
[info] Resolving key references (15300 settings) ...
[info] Set current project to scastie (in build file:/Users/wesleymaldonado/ws/scastie/)
[info] No license specified
[info]  org.scastie:api_sjs0.6_2.11:0.25.0+dd51be0d2b7ac978e4aa654fb8fb5a7802368e6f
[info]  org.scastie:api_sjs0.6_2.12:0.25.0+dd51be0d2b7ac978e4aa654fb8fb5a7802368e6f
[info]  org.scastie:api_sjs0.6_2.13:0.25.0+dd51be0d2b7ac978e4aa654fb8fb5a7802368e6f
[info]  org.scastie:api_sjs0.6_2.14:0.25.0+dd51be0d2b7ac978e4aa654fb8fb5a7802368e6f
[info]  org.scastie:api_sjs0.6_2.15:0.25.0+dd51be0d2b7ac978e4aa654fb8fb5a7802368e6f
[info]
[info] BSD 3-Clause
[info]  org.scala-lang:scala-reflect:2.11.11
[info]
[info] BSD New
[info]  org.scala-js:scalajs-library_2.11:0.6.18
[info]
[info] MIT
[info]  org.scala-js:scalajs-dom_sjs0.6_2.11:0.9.2
[info]
[info] MIT license
[info]  com.lihaoyi:autowire_sjs0.6_2.11:0.2.6
[info]  com.lihaoyi:upickle_sjs0.6_2.11:0.4.4
[info]  com.lihaoyi:derive_s.v1js0.6_2.11:0.4.4
[info]  com.lihaoyi:sourcecode_sjs0.6_2.11:0.1.3
[info] No license specified
[info]  org.scastie:api_2.12:0.25.0+dd51be0d2bg7ac978e4aa654fb8fb5a7802368e6f
CMDOUTPUT

    describe '.current_packages' do
      before do
        allow(Dir).to receive(:chdir).with(Pathname('/fake/path')) { |&block| block.call }
      end

      it 'lists all the current packages' do
        allow(subject).to receive(:capture).with('sbt -no-colors dependencyLicenseInfo').and_return([output, true])

        current_packages = subject.current_packages
        expect(current_packages.map(&:name)).to eq(["uuid", "jiffy"])
        expect(current_packages.map(&:install_path)).to eq([Pathname("deps/uuid"), Pathname("deps/jiffy")])
      end

      it "fails when command fails" do
        allow(subject).to receive(:capture).with(/sbt/).and_return(['Some error', false]).once
        expect { subject.current_packages }.to raise_error(RuntimeError)
      end
    end
  end
end
