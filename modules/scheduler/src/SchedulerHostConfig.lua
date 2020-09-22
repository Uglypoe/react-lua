-- (align) This implementation is converted from the "naive" implementation that
-- the React scheduler falls bak on in the absence of certain DOM APIs.
--
-- This is likely to be the implementation that React Native applications run
-- with, and should be considered sufficiently sophisticated. More research
-- needs to be done to verify this.
return function(Timeout, getCurrentTime)
	local setTimeout = Timeout.setTimeout
	local clearTimeout = Timeout.clearTimeout

	-- TODO(align): This code is from a naive implementation used as a fallback for
	-- non-DOM environments. It's unclear if this version of the logic was ever
	-- meant to be used in _any_ environment, so we may need to essentially rewrite
	-- this module using a combination of the DOM-dependent impl (commented out
	-- below) and our own re-implementation of DOM APIs
	local _callback = nil
	local _timeoutID = nil

	local function _flushCallback()
		if _callback ~= nil then
			local ok, result = pcall(function()
				local currentTime = getCurrentTime()
				local hasRemainingTime = true
				_callback(hasRemainingTime, currentTime)
				_callback = nil
			end)
			
			if not ok then
				setTimeout(_flushCallback, 0)
				error(result)
			end
		end
	end

	local function requestHostCallback(cb)
		if _callback ~= nil then
			-- Protect against re-entrancy.
			setTimeout(requestHostCallback, 0, cb)
		else
			_callback = cb
			setTimeout(_flushCallback, 0)
		end
	end

	return {
		getCurrentTime = getCurrentTime,
		requestHostCallback = requestHostCallback,
		cancelHostCallback = function()
			_callback = nil
		end,
		requestHostTimeout = function(cb, ms)
			_timeoutID = setTimeout(cb, ms)
		end,
		cancelHostTimeout = function()
			clearTimeout(_timeoutID)
		end,
		shouldYieldToHost = function()
			return false
		end,
		requestPaint = function()
		end,
		forceFrameRate = function()
		end,
	}
end

-- -- Capture local references to native APIs, in case a polyfill overrides them.
-- local setTimeout = Timeout.setTimeout
-- local clearTimeout = Timeout.clearTimeout

-- local isMessageLoopRunning = false
-- local scheduledHostCallback = nil
-- local taskTimeoutID = -1

-- -- Scheduler periodically yields in case there is other work on the main
-- -- thread, like user events. By default, it yields multiple times per frame.
-- -- It does not attempt to align with frame boundaries, since most tasks don't
-- -- need to be frame aligned; for those that do, use requestAnimationFrame.
-- local yieldInterval = 5
-- local deadline = 0

-- -- TODO(align): Restore enableIsInputPending flag if needed
-- -- `isInputPending` is not available. Since we have no way of knowing if
-- -- there's pending input, always yield at the end of the frame.
-- shouldYieldToHost = function()
-- 	return getCurrentTime() >= deadline
-- end

-- -- TODO(align): With flagged logic removed, we no longer have any meaningful
-- -- implementations for this function. Should we remove it, and remove uses?
-- --
-- -- Since we yield every frame regardless, `requestPaint` has no effect.
-- requestPaint = function()
-- end

-- forceFrameRate = function(fps)
-- 	if fps < 0 or fps > 125 then
-- 		warn(
-- 			"forceFrameRate takes a positive int between 0 and 125, " ..
-- 			"forcing frame rates higher than 125 fps is not supported"
-- 		)
-- 		return
-- 	end
-- 	if fps > 0 then
-- 		yieldInterval = math.floor(1000 / fps)
-- 	else
-- 		-- reset the framerate
-- 		yieldInterval = 5
-- 	end
-- end

-- local channel = new MessageChannel()
-- local port = channel.port2

-- local function performWorkUntilDeadline()
-- 	if scheduledHostCallback ~= nil then
-- 		local currentTime = getCurrentTime()
-- 		-- Yield after `yieldInterval` ms, regardless of where we are in the vsync
-- 		-- cycle. This means there's always time remaining at the beginning of
-- 		-- the message event.
-- 		deadline = currentTime + yieldInterval
-- 		local hasTimeRemaining = true
-- 		local ok, result = pcall(function()
-- 			local hasMoreWork = scheduledHostCallback(
-- 				hasTimeRemaining,
-- 				currentTime
-- 			)
-- 			if not hasMoreWork then
-- 				isMessageLoopRunning = false
-- 				scheduledHostCallback = nil
-- 			else
-- 				-- If there's more work, schedule the next message event at the end
-- 				-- of the preceding one.
-- 				port.postMessage(nil)
-- 			end
-- 		end)

-- 		if not ok then
-- 			-- If a scheduler task throws, exit the current browser task so the
-- 			-- error can be observed.
-- 			port.postMessage(nil)
-- 			error(result)
-- 		end
-- 	else
-- 		isMessageLoopRunning = false
-- 	end
-- end
-- channel.port1.onmessage = performWorkUntilDeadline

-- requestHostCallback = function(callback)
-- 	scheduledHostCallback = callback
-- 	if not isMessageLoopRunning then
-- 		isMessageLoopRunning = true
-- 		port.postMessage(nil)
-- 	end
-- end

-- cancelHostCallback = function()
-- 	scheduledHostCallback = nil
-- end

-- requestHostTimeout = function(callback, ms)
-- 	taskTimeoutID = setTimeout(function()
-- 		callback(getCurrentTime())
-- 	end, ms);
-- end

-- cancelHostTimeout = function()
-- 	clearTimeout(taskTimeoutID)
-- 	taskTimeoutID = -1
-- end

-- return {
-- 	requestHostCallback = requestHostCallback,
-- 	cancelHostCallback = cancelHostCallback,
-- 	requestHostTimeout = requestHostTimeout,
-- 	cancelHostTimeout = cancelHostTimeout,
-- 	shouldYieldToHost = shouldYieldToHost,
-- 	requestPaint = requestPaint,
-- 	getCurrentTime = getCurrentTime,
-- 	forceFrameRate = forceFrameRate,
-- }