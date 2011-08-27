# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mime-types}
  s.version = "1.16"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Austin Ziegler}]
  s.cert_chain = [%q{-----BEGIN CERTIFICATE-----
MIIDNjCCAh6gAwIBAgIBADANBgkqhkiG9w0BAQUFADBBMQ8wDQYDVQQDDAZhdXN0
aW4xGTAXBgoJkiaJk/IsZAEZFglydWJ5Zm9yZ2UxEzARBgoJkiaJk/IsZAEZFgNv
cmcwHhcNMDcxMTMwMDE0OTAwWhcNMDgxMTI5MDE0OTAwWjBBMQ8wDQYDVQQDDAZh
dXN0aW4xGTAXBgoJkiaJk/IsZAEZFglydWJ5Zm9yZ2UxEzARBgoJkiaJk/IsZAEZ
FgNvcmcwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDOSg1riVV22ord
q0t4YVx57GDPMqdjlnQ5M7D9iBnnW0c8pifegbb0dm+mC9hJSuPtcJS53+YPTy9F
wlZbjI2cN+P0QLUUTOlZus2sHq7Pr9jz2nJf8hCT7t5Vlopv1N/xlKtXqpcyEkhJ
JHTrxe1avGwuq8DIAIN01moQJ+hJlgrnR2eRJRazTGiXKBLGAFXDl/Agn78MHx6w
pzZ2APydo6Nuk7Ktq1MvCHzLzCACbOlYawFk3/9dbsmHhVjsi6YW+CpEJ2BnTy8X
JBXlyNTk1JxDmcs3RzNr+9AmDQh3u4LcmJnWxtLJo9e7UBxH/bwVORJyf8dAOmOm
HO6bFTLvAgMBAAGjOTA3MAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdDgQW
BBT9e1+pFfcV1LxVxILANqLtZzI/XTANBgkqhkiG9w0BAQUFAAOCAQEAhg42pvrL
uVlqAaHqV88KqgnW2ymCWm0ePohicFTcyiS5Yj5cN3OXLsPV2x12zqvLCFsfpA4u
D/85rngKFHITSW0h9e/CIT/pwQA6Uuqkbr0ypkoU6mlNIDS10PlK7aXXFTCP9X3f
IndAajiNRgKwb67nj+zpQwHa6dmooyRQIRRijrMKTgY6ebaCCrm7J3BLLTJAyxOW
+1nD0cuTkBEKIuSVK06E19Ml+xWt2bdtS9Wz/8jHivJ0SvUpbmhKVzh1rBslwm65
JpQgg3SsV23vF4qkCa2dt1FL+FeWJyCdj23DV3598X72RYiK3D6muWURck16jqeA
BRvUFuFHOwa/yA==
-----END CERTIFICATE-----
}]
  s.date = %q{2009-03-02}
  s.description = %q{MIME::Types for Ruby originally based on and synchronized with MIME::Types for Perl by Mark Overmeer, copyright 2001 - 2009. As of version 1.15, the data format for the MIME::Type list has changed and the synchronization will no longer happen.}
  s.email = [%q{austin@rubyforge.org}]
  s.extra_rdoc_files = [%q{History.txt}, %q{Install.txt}, %q{Licence.txt}, %q{README.txt}]
  s.files = [%q{History.txt}, %q{Install.txt}, %q{Licence.txt}, %q{README.txt}]
  s.homepage = %q{http://mime-types.rubyforge.org/}
  s.rdoc_options = [%q{--main}, %q{README.txt}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{mime-types}
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Manages a MIME Content-Type database that will return the Content-Type for a given filename.}

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<archive-tar-minitar>, ["~> 0.5"])
      s.add_development_dependency(%q<nokogiri>, ["~> 1.2"])
      s.add_development_dependency(%q<rcov>, ["~> 0.8"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.3"])
    else
      s.add_dependency(%q<archive-tar-minitar>, ["~> 0.5"])
      s.add_dependency(%q<nokogiri>, ["~> 1.2"])
      s.add_dependency(%q<rcov>, ["~> 0.8"])
      s.add_dependency(%q<hoe>, [">= 1.8.3"])
    end
  else
    s.add_dependency(%q<archive-tar-minitar>, ["~> 0.5"])
    s.add_dependency(%q<nokogiri>, ["~> 1.2"])
    s.add_dependency(%q<rcov>, ["~> 0.8"])
    s.add_dependency(%q<hoe>, [">= 1.8.3"])
  end
end
