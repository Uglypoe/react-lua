-- upstream: https://github.com/facebook/react/blob/96ac799eace5d989de3b4f80e6414e94a08ff77a/packages/react-reconciler/src/ReactFiberRoot.new.js
--[[*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @flow
]]

local Workspace = script.Parent.Parent

local ReactInternalTypes = require(script.Parent.ReactInternalTypes)
type FiberRoot = ReactInternalTypes.FiberRoot;
type SuspenseHydrationCallbacks = ReactInternalTypes.SuspenseHydrationCallbacks;
local ReactRootTags = require(script.Parent.ReactRootTags)
type RootTag = ReactRootTags.RootTag;

local ReactFiberHostConfig = require(script.Parent.ReactFiberHostConfig)
local noTimeout = ReactFiberHostConfig.noTimeout
local supportsHydration = ReactFiberHostConfig.supportsHydration
local ReactFiber = require(script.Parent["ReactFiber.new"])
local createHostRootFiber = ReactFiber.createHostRootFiber
local ReactFiberLane = require(script.Parent.ReactFiberLane)
local NoLanes = ReactFiberLane.NoLanes
local NoLanePriority = ReactFiberLane.NoLanePriority
local NoTimestamp = ReactFiberLane.NoTimestamp
local createLaneMap = ReactFiberLane.createLaneMap
local ReactFeatureFlags = require(Workspace.Shared.ReactFeatureFlags)
local enableSchedulerTracing = ReactFeatureFlags.enableSchedulerTracing
local enableSuspenseCallback = ReactFeatureFlags.enableSuspenseCallback
-- local Scheduler = require(Workspace.Scheduler.tracing)
-- local unstable_getThreadID = Scheduler.unstable_getThreadID
local ReactUpdateQueue = require(script.Parent["ReactUpdateQueue.new"])
local initializeUpdateQueue = ReactUpdateQueue.initializeUpdateQueue
local LegacyRoot = ReactRootTags.LegacyRoot
local BlockingRoot = ReactRootTags.BlockingRoot
local ConcurrentRoot = ReactRootTags.ConcurrentRoot

local exports = {}

local function FiberRootNode(containerInfo, tag, hydrate)
	local rootNode = {}

	rootNode.tag = tag
	rootNode.containerInfo = containerInfo
	rootNode.pendingChildren = nil
	rootNode.current = nil
	rootNode.pingCache = nil
	rootNode.finishedWork = nil
	rootNode.timeoutHandle = noTimeout
	rootNode.context = nil
	rootNode.pendingContext = nil
	rootNode.hydrate = hydrate
	rootNode.callbackNode = nil
	rootNode.callbackPriority = NoLanePriority
	rootNode.eventTimes = createLaneMap(NoLanes)
	rootNode.expirationTimes = createLaneMap(NoTimestamp)

	rootNode.pendingLanes = NoLanes
	rootNode.suspendedLanes = NoLanes
	rootNode.pingedLanes = NoLanes
	rootNode.expiredLanes = NoLanes
	rootNode.mutableReadLanes = NoLanes
	rootNode.finishedLanes = NoLanes

	rootNode.entangledLanes = NoLanes
	rootNode.entanglements = createLaneMap(NoLanes)

	if supportsHydration then
		rootNode.mutableSourceEagerHydrationData = nil
	end

	if enableSchedulerTracing then
		-- FIXME (roblox): Port Scheduler tracing
		-- rootNode.interactionThreadID = unstable_getThreadID()
		rootNode.memoizedInteractions = {}
		rootNode.pendingInteractionMap = {}
	end
	if enableSuspenseCallback then
		rootNode.hydrationCallbacks = nil
	end

	if _G.__DEV__ then
		if tag == BlockingRoot then
			rootNode._debugRootType = "createBlockingRoot()"
		elseif tag == ConcurrentRoot then
			rootNode._debugRootType = "createRoot()"
		elseif tag == LegacyRoot then
			rootNode._debugRootType = "createLegacyRoot()"
		end
	end

	return rootNode
end

exports.createFiberRoot = function(
	containerInfo: any,
	tag: RootTag,
	hydrate: boolean,
	hydrationCallbacks: SuspenseHydrationCallbacks?
): FiberRoot
	local root: FiberRoot = FiberRootNode(containerInfo, tag, hydrate)
	if enableSuspenseCallback then
		root.hydrationCallbacks = hydrationCallbacks
	end

	-- Cyclic construction. This cheats the type system right now because
	-- stateNode is any.
	local uninitializedFiber = createHostRootFiber(tag)
	root.current = uninitializedFiber
	uninitializedFiber.stateNode = root

	initializeUpdateQueue(uninitializedFiber)

	return root
end

return exports
