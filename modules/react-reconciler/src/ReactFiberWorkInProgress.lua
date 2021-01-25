-- ROBLOX deviation: this is an extraction of a single state field
-- (and associated mutation/getters) from ReactFiberWorkLooop.new
-- which allows us to break dependency cycles involving that module
local ReactFiberLane = require(script.Parent.ReactFiberLane)
local _workInProgressRootSkippedLanes: Lanes = ReactFiberLane.NoLanes
local mergeLanes = ReactFiberLane.mergeLanes
type Lanes = ReactFiberLane.Lanes;
type Lane = ReactFiberLane.Lane;

local exports = {}

exports.workInProgressRootSkippedLanes = function(value)
	if value == nil then
		return _workInProgressRootSkippedLanes
	end

	_workInProgressRootSkippedLanes = value
	return nil
end

exports.markSkippedUpdateLanes = function(lane: Lane | Lanes)
	_workInProgressRootSkippedLanes = mergeLanes(
	  lane,
	  _workInProgressRootSkippedLanes
	)
end

return exports