--[[*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 *
 ]]
local Workspace = script.Parent.Parent
local Timers = require(Workspace.JSPolyfill.Timers)

return function(task)
	-- deviation: Replace with setImmediate once we create an equivalent polyfill
	return Timers.setTimeout(task, 0)
end