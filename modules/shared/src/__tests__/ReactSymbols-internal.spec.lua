-- upstream: https://github.com/facebook/react/blob/cdbfa6b5dd692220e5996ec453d46fc10aff046a/packages/shared/__tests__/ReactSymbols-test.internal.js
--[[*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @emails react-core
]]
--!strict

return function()
	describe('ReactSymbols', function()
		-- deviation: This doesn't have any affect for this test
		-- beforeEach(() => jest.resetModules());

		local function expectToBeUnique(keyValuePairs)
			local map = {}
			for key, value in pairs(keyValuePairs) do
				if map[value] ~= nil then
					error(string.format("%s value %s is the same as %s", key, tostring(value), map[value]))
				end
				map[value] = key
			end
		end

		-- deviation: Symbol values are not used
		itSKIP('Symbol values should be unique', function()
			-- expectToBeUnique(require(script.Parent.ReactSymbols));
		end)

		it('numeric values should be unique', function()
			-- deviation: We don't use symbol anyways, so it's no use to
			-- override it. We also don't need to filter any values, since
			-- they're internal-only.
			local ReactSymbols = require(script.Parent.Parent.ReactSymbols)
			expectToBeUnique(ReactSymbols)

			-- const originalSymbolFor = global.Symbol.for;
			-- global.Symbol.for = null;
			-- try {
			-- 	entries = Object.entries(require('shared/ReactSymbols')).filter(
			-- 		// REACT_ASYNC_MODE_TYPE and REACT_CONCURRENT_MODE_TYPE have the same numeric value
			-- 		// for legacy backwards compatibility
			-- 		([key]) => key !== 'REACT_ASYNC_MODE_TYPE',
			-- 	);
			-- 	expectToBeUnique(entries);
			-- } finally {
			-- 	global.Symbol.for = originalSymbolFor;
			-- }
		end)
	end)
end
