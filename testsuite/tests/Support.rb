# encoding: utf-8

module Yast
  class SupportClient < Client
    def main
      # testedfiles: Support.ycp

      Yast.include self, "testsuite.rb"
      TESTSUITE_INIT([], nil)

      Yast.import "Support"

      DUMP("Support::Modified")
      TEST(lambda { Support.Modified }, [], nil)

      nil
    end
  end
end

Yast::SupportClient.new.main
