local Canonicalizer = require("escher.canonicalizer")
local TestSuite = require("spec.testsuite")

describe("Canonicalizer", function()
  describe(".canonicalizeRequest", function()

    TestSuite.signing.forEach(function(filename, testData)

      local expected = testData.expected.canonicalizedRequest

      if not expected then
        return
      end

      local config, request, headersToSign = testData.config, testData.request, testData.headersToSign

      it("should return canonicalized form of request " .. filename, function()
        local actual = Canonicalizer(config):canonicalizeRequest(request, headersToSign)

        assert.is_equal(expected, actual)
      end)

    end)

  end)
end)
