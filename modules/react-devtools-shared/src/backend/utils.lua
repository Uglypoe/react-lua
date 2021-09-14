-- ROBLOX upstream: https://github.com/facebook/react/blob/v17.0.1/packages/react-devtools-shared/src/backend/utils.js
--[[*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
]]
local Packages = script.Parent.Parent.Parent

local LuauPolyfill = require(Packages.LuauPolyfill)
local Set = LuauPolyfill.Set
local Array = LuauPolyfill.Array
type Array<T> = { [number]: T }
local Object = LuauPolyfill.Object
type Object = { [string]: any }

local hydration = require(script.Parent.Parent.hydration)
local dehydrate = hydration.dehydrate

local ComponentsTypes = require(script.Parent.Parent.devtools.views.Components.types)
type DehydratedData = ComponentsTypes.DehydratedData

-- ROBLOX deviation: Use HttpService for JSON
local JSON = game:GetService("HttpService")

local exports: any = {}

exports.cleanForBridge = function(
	data: Object | nil,
	isPathAllowed: (path: Array<string | number>) -> boolean,
	path: Array<string | number>?
): DehydratedData | nil
	path = path or {}
	if data ~= nil then
		local cleanedPaths = {}
		local unserializablePaths = {}
		local cleanedData = dehydrate(
			data,
			cleanedPaths,
			unserializablePaths,
			path,
			isPathAllowed
		)
		return {
			data = cleanedData,
			cleaned = cleanedPaths,
			unserializable = unserializablePaths,
		}
	else
		return nil
	end
end
exports.copyToClipboard = function(value: any): ()
	-- ROBLOX TODO: we will need a different implementation for this
	-- local safeToCopy = serializeToString(value)
	-- local text = (function()
	--     if safeToCopy == nil then
	--         return'undefined'
	--     end

	--     return safeToCopy
	-- end)()
	-- local clipboardCopyText = window.__REACT_DEVTOOLS_GLOBAL_HOOK__.clipboardCopyText

	-- if typeof(clipboardCopyText) == 'function' then
	--     clipboardCopyText(text).catch(function(err) end)
	-- else
	--     copy(text)
	-- end
end

exports.copyWithDelete = function(
	obj: Object | Array<any>,
	path: Array<string | number>,
	index: number
): Object | Array<any>
	-- ROBLOX deviation: 1-indexed
	index = index or 1
	local key = path[index]
	local updated = Array.isArray(obj) and Array.slice(obj) or Object.assign({}, obj)

	-- ROBLOX deviation: 1-indexed, check for last element
	if index == #path then
		if Array.isArray(updated) then
			updated.splice(key, 1)
		else
			updated[key] = nil
		end
	else
		updated[key] = exports.copyWithDelete((obj :: any)[key], path, index + 1)
	end

	return updated
end

-- This function expects paths to be the same except for the final value.
-- e.g. ['path', 'to', 'foo'] and ['path', 'to', 'bar']
exports.copyWithRename = function(
	obj: Object | Array<any>,
	oldPath: Array<string | number>,
	newPath: Array<string | number>,
	index: number
): Object | Array<any>
	-- ROBLOX deviation: 1-indexed
	index = index or 1
	local oldKey = oldPath[index]
	local updated = Array.isArray(obj) and Array.slice(obj) or Object.assign({}, obj)

	-- ROBLOX deviation: 1-indexed, check for last element
	if index == #oldPath then
		local newKey = newPath[index]

		updated[newKey] = updated[oldKey]

		if Array.isArray(updated) then
			updated.splice(oldKey, 1)
		else
			updated[oldKey] = nil
		end
	else
		updated[oldKey] = exports.copyWithRename(
			(obj :: any)[oldKey],
			oldPath,
			newPath,
			index + 1
		)
	end

	return updated
end

exports.copyWithSet = function(
	obj: Object | Array<any>,
	path: Array<string | number>,
	value: any,
	index: number
): Object | Array<any>
	-- ROBLOX deviation: 1-indexed
	index = index or 1

	-- ROBLOX deviation: 1-indexed, check for out of bounds
	if index > #path then
		return value
	end

	local key = path[index]
	local updated = Array.isArray(obj) and Array.slice(obj) or Object.assign({}, obj)

	updated[key] = exports.copyWithSet((obj :: any)[key], path, value, index + 1)

	return updated
end

exports.serializeToString = function(data: any): string
	local cache = Set.new()

	return JSON.JSONEncode(data, function(key, value)
		-- ROBLOX deviation: use 'table' not object
		if typeof(value) == "table" and value ~= nil then
			if cache:has(value) then
				return
			end

			cache:add(value)
		end
		-- ROBLOX deviation: not Luau
		-- if typeof(value) == 'bigint' then
		-- 	return tostring(value) + 'n'
		-- end

		return value
	end)
end

return exports