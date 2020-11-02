--[[*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @emails react-core
 * @jest-environment node
]]
return function()
	local Workspace = script.Parent.Parent.Parent
	local React = require(Workspace.React)
	local ReactShallowRenderer = require(script.Parent.Parent.ReactShallowRenderer)

	local createRenderer = ReactShallowRenderer.createRenderer

	describe('ReactShallowRenderer with hooks', function()
		it('should work with useState', function()
			-- FIXME: Appease roblox-cli
			local expect: any = expect
			local function SomeComponent(props)
				local name = React.useState(props.defaultName)

				return React.createElement("TextLabel", {
					Text = "Your name is: " .. name,
				})
			end

			local shallowRenderer = createRenderer()
			local result = shallowRenderer:render(
				React.createElement(SomeComponent, {
					defaultName = "Dominic",
				})
			)

			expect(result).toEqual(
				React.createElement("TextLabel", {
					Text = "Your name is: Dominic",
				})
			)

			result = shallowRenderer:render(
				React.createElement(SomeComponent, {
					defaultName = "Should not use this name",
				})
			)

			expect(result).toEqual(
				React.createElement("TextLabel", {
					Text = "Your name is: Dominic",
				})
			)
		end)

		it('should work with updating a value from useState', function()
			-- FIXME: Appease roblox-cli
			local expect: any = expect
			local function SomeComponent(props)
				local name, updateName = React.useState(props.defaultName)

				if name ~= 'Dan' then
					updateName('Dan')
				end

				return
					React.createElement("Frame", nil, {
						React.createElement("TextLabel", {
							Text = "Your name is: " .. name
						})
					})
			end

			local shallowRenderer = createRenderer()
			local result = shallowRenderer:render(
				React.createElement(SomeComponent, {defaultName='Dominic'})
			)

			expect(result).toEqual(
				React.createElement("Frame", nil, {
					React.createElement("TextLabel", {
						Text = "Your name is: " .. "Dan"
					})
				})
			)
		end)

		it('should work with updating a derived value from useState', function()
			-- FIXME: Appease roblox-cli
			local expect: any = expect
			local _updateName

			local function SomeComponent(props)
				local name, updateName = React.useState(props.defaultName)
				local prevName, updatePrevName = React.useState(props.defaultName)
				local letter, updateLetter = React.useState(string.sub(name, 1, 1))

				_updateName = updateName

				if name ~= prevName then
					updatePrevName(name)
					updateLetter(string.sub(name, 1, 1))
				end

				return
					React.createElement("Frame", nil, {
						React.createElement("TextLabel", {
							Text = "Your name is: " .. name .. ' (' .. tostring(letter) .. ')'
						})
					})
			end

			local shallowRenderer = createRenderer()
			local result = shallowRenderer:render(
				React.createElement(SomeComponent, {defaultName='Sophie'})
			)

			expect(result).toEqual(
				React.createElement("Frame", nil, {
					React.createElement("TextLabel", {
						Text = "Your name is: " .. "Sophie (S)"
					})
				})
			)

			result = shallowRenderer:render(
				React.createElement(SomeComponent, {defaultName='Dan'})
			)
			expect(result).toEqual(
				React.createElement("Frame", nil, {
					React.createElement("TextLabel", {
						Text = "Your name is: " .. "Sophie (S)"
					})
				})
			)

			_updateName('Dan')
			expect(shallowRenderer:getRenderOutput()).toEqual(
				React.createElement("Frame", nil, {
					React.createElement("TextLabel", {
						Text = "Your name is: " .. "Dan (D)"
					})
				})
			)
		end)

		it('should work with useReducer', function()
			-- FIXME: Appease roblox-cli
			local expect: any = expect
			local function reducer(state, action)
				if action.type == 'increment' then
					return {count = state.count + 1}
				elseif action.type == 'decrement' then
					return {count = state.count - 1}
				else
					error('impossible')
				end
			end

			local function SomeComponent(props)
				local state = React.useReducer(reducer, props,
					function(p)
						return {
							count = p.initialCount,
						}
					end
				)

				return
					React.createElement("Frame", nil, {
						React.createElement("TextLabel", {
							"The counter is at: " .. tostring(state.count)
						})
					})
			end

			local shallowRenderer = createRenderer()
			local result = shallowRenderer:render(
				React.createElement(SomeComponent, {initialCount=0})
			)
			expect(result).toEqual(
				React.createElement("Frame", nil, {
					React.createElement("TextLabel", {
						"The counter is at: 0"
					})
				})
			)

			result = shallowRenderer:render(
				React.createElement(SomeComponent, {initialCount=10})
			)

			expect(result).toEqual(
				React.createElement("Frame", nil, {
					React.createElement("TextLabel", {
						"The counter is at: 0"
					})
				})
			)
		end)

		it('should work with a dispatched state change for a useReducer', function()
			-- FIXME: Appease roblox-cli
			local expect: any = expect
			local function reducer(state, action)
				if action.type == 'increment' then
					return {count = state.count + 1}
				elseif action.type == 'decrement' then
					return {count = state.count - 1}
				else
					error('impossible')
				end
			end

			local function SomeComponent(props)
				local state, dispatch = React.useReducer(reducer, props,
					function(p)
						return {
							count = p.initialCount,
						}
					end
				)

				if (state.count == 0) then
					dispatch({type = 'increment'})
				end
				return
					React.createElement("Frame", nil, {
						React.createElement("TextLabel", {
							"The counter is at: " .. tostring(state.count)
						})
					})
			end

			local shallowRenderer = createRenderer()
			local result = shallowRenderer:render(
				React.createElement(SomeComponent, {initialCount=0})
			)

			expect(result).toEqual(
				React.createElement("Frame", nil, {
					React.createElement("TextLabel", {
						"The counter is at: 1"
					})
				})
			)
		end)

		it('should not trigger effects', function()
			-- FIXME: Appease roblox-cli
			local expect: any = expect
			local effectsCalled = {}

			local function SomeComponent(props)
				React.useEffect(function()
					table.insert(effectsCalled, 'useEffect')
				end)

				React.useLayoutEffect(function()
					table.insert(effectsCalled, 'useEffect')
				end)

				return React.createElement("Text", nil, "Hello world")
			end

			local shallowRenderer = createRenderer()
			shallowRenderer:render(React.createElement(SomeComponent))

			expect(effectsCalled).toEqual({})
		end)

		it('should work with useRef', function()
			-- FIXME: Appease roblox-cli
			local expect: any = expect
			local function SomeComponent()
				local randomNumberRef = React.useRef({number = math.random()})

				return
					React.createElement("Frame", nil,
						React.createElement("TextLabel",
						{Text = "The random number is: " .. tostring(randomNumberRef.current.number)}
					)
				)
			end

			local shallowRenderer = createRenderer()
			local firstResult = shallowRenderer:render(React.createElement(SomeComponent))
			local secondResult = shallowRenderer:render(React.createElement(SomeComponent))

			expect(firstResult).toEqual(secondResult)
		end)

		it('should work with useMemo', function()
			-- FIXME: Appease roblox-cli
			local expect: any = expect
			local function SomeComponent()
				local randomNumber = React.useMemo(
					function()
						return {number = math.random()}
					end,
					{}
				)

				return
					React.createElement("Frame", nil,
						React.createElement("TextLabel",
							{Text = "The random number is: " .. tostring(randomNumber.number)}
						)
					)
			end

			local shallowRenderer = createRenderer()
			local firstResult = shallowRenderer:render(React.createElement(SomeComponent))
			local secondResult = shallowRenderer:render(React.createElement(SomeComponent))

			expect(firstResult).toEqual(secondResult)
		end)

		-- ROBLOX TODO: implement createContext and then re-enable
		it('should work with useContext', function()
			-- FIXME: Appease roblox-cli
			local expect: any = expect
			local SomeContext = React.createContext('default')

			local function SomeComponent()
				local value = React.useContext(SomeContext)

				return
					React.createElement("Frame", nil,
						React.createElement("TextLabel",
							{Text = tostring(value)}
						)
					)
			end

			local shallowRenderer = createRenderer()
			local result = shallowRenderer:render(React.createElement(SomeComponent))

			expect(result).toEqual(
				React.createElement("Frame", nil,
					React.createElement("TextLabel",
						{Text = "default"}
					)
				)
			)
		end)

		it('should not leak state when component type changes', function()
			-- FIXME: Appease roblox-cli
			local expect: any = expect
			local function SomeComponent(props)
				local name = React.useState(props.defaultName)

				return React.createElement("TextLabel", {
					Text = "Your name is: " .. name,
				})
			end

			local function SomeOtherComponent(props)
				local name = React.useState(props.defaultName)

				return React.createElement("TextLabel", {
					Text = "Your name is: " .. name,
				})
			end

			local shallowRenderer = createRenderer()
			local result = shallowRenderer:render(
				React.createElement(SomeComponent, {defaultName='Dominic'})
			)
			expect(result).toEqual(
				React.createElement("TextLabel", {
					Text = "Your name is: " .. "Dominic",
				})
			)

			result = shallowRenderer:render(
				React.createElement(SomeOtherComponent, {defaultName='Dan'})
			)

			expect(result).toEqual(
				React.createElement("TextLabel", {
					Text = "Your name is: " .. "Dan",
				})
			)
		end)

		it('should work with with forwardRef + any hook', function()
			-- FIXME: Appease roblox-cli
			local expect: any = expect
			local SomeComponent = React.forwardRef(function(props, ref)
				local randomNumberRef = React.useRef({number = math.random()})

				return
					React.createElement("Frame", { ref=ref },
						React.createElement("TextLabel", {
							Text = "The random number is: " .. tostring(randomNumberRef.current.number)
						})
					)
			end)

			local shallowRenderer = createRenderer()
			local firstResult = shallowRenderer:render(React.createElement(SomeComponent))
			local secondResult = shallowRenderer:render(React.createElement(SomeComponent))

			expect(firstResult).toEqual(secondResult)
		end)

		it('should update a value from useState outside the render', function()
			-- FIXME: Appease roblox-cli
			local expect: any = expect
			local _dispatch

			local function SomeComponent(props)
				local count, dispatch = React.useReducer(
					function(s, a)
						if a == 'inc' then
							return s + 1
						end
						return s
					end,
					0
				)
				local name, updateName = React.useState(props.defaultName)
				_dispatch = function() return dispatch('inc') end

				return React.createElement("Frame", {
					onClick=function() updateName('Dan') end},
					React.createElement("TextLabel", {
						Text = "Your name is: " .. name .. " (" .. count .. ")",
					})
				)
			end

			local shallowRenderer = createRenderer()
			local element = React.createElement(SomeComponent, {defaultName='Dominic'})
			local result = shallowRenderer:render(element)
			expect(result.props.children).toEqual(
				React.createElement("TextLabel", {
					Text = "Your name is: Dominic (0)"
				})
			)

			result.props.onClick()
			local updated = shallowRenderer:render(element)
			expect(updated.props.children).toEqual(
				React.createElement("TextLabel", {
					Text = "Your name is: Dan (0)"
				})
			)

			_dispatch('foo')
			updated = shallowRenderer:render(element)
			expect(updated.props.children).toEqual(
				React.createElement("TextLabel", {
					Text = "Your name is: Dan (1)"
				})
			)

			_dispatch('inc')
			updated = shallowRenderer:render(element)
			expect(updated.props.children).toEqual(
				React.createElement("TextLabel", {
					Text = "Your name is: Dan (2)"
				})
			)
		end)

		it('should ignore a foreign update outside the render', function()
			-- FIXME: Appease roblox-cli
			local expect: any = expect
			local _updateCountForFirstRender

			local function SomeComponent()
				local count, updateCount = React.useState(0)
				if (not _updateCountForFirstRender) then
					_updateCountForFirstRender = updateCount
				end
				return count
			end

			local shallowRenderer = createRenderer()
			local element = React.createElement(SomeComponent)
			local result = shallowRenderer:render(element)
			expect(result).toEqual(0)
			_updateCountForFirstRender(1)
			result = shallowRenderer:render(element)
			expect(result).toEqual(1)

			shallowRenderer:unmount()
			result = shallowRenderer:render(element)
			expect(result).toEqual(0)
			_updateCountForFirstRender(1) -- Should be ignored.
			result = shallowRenderer:render(element)
			expect(result).toEqual(0)
		end)

		it('should not forget render phase updates', function()
			-- FIXME: Appease roblox-cli
			local expect: any = expect
			local _updateCount

			local function SomeComponent()
				local count, updateCount = React.useState(0)
				_updateCount = updateCount
				if (count < 5) then
					updateCount(function(x) return x + 1 end)
				end
				return count
			end

			local shallowRenderer = createRenderer()
			local element = React.createElement(SomeComponent)
			local result = shallowRenderer:render(element)
			expect(result).toEqual(5)

			_updateCount(10)
			result = shallowRenderer:render(element)
			expect(result).toEqual(10)

			_updateCount(function(x) return  x + 1 end)
			result = shallowRenderer:render(element)
			expect(result).toEqual(11)

			_updateCount(function(x) return  x - 10 end)
			result = shallowRenderer:render(element)
			expect(result).toEqual(5)
		end)
	end)
end