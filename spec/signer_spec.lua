local date = require("date")
local Signer = require("escher.signer")
local TestSuite = require("spec.testsuite")

describe("Signer", function()
  describe(".getStringToSign", function()

    TestSuite.signing.forEach(function(filename, testData)

      local expected = testData.expected.stringToSign

      if not expected then
        return
      end

      local config, request, headersToSign = testData.config, testData.request, testData.headersToSign

      it("should return unencrypted request signature " .. filename, function()
        local signDate, secret = date(config.date), config.apiSecret
        local actual = Signer(config):getStringToSign(request, headersToSign, signDate, secret)

        assert.is_equal(expected, actual)
      end)

    end)

  end)
end)
