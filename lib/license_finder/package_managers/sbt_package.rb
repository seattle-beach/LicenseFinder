module LicenseFinder
  class SbtPackage < Package
    def package_manager
      'sbt'
    end
  end
end
