--[[*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @flow
]]

-- deviation: Common types
type Array<T> = { [number]: T };
type Object = { [any]: any };

-- deviation: disabled flow types
-- export type ReactNode =
--   | React$Element<any>
--   | ReactPortal
--   | ReactText
--   | ReactFragment
--   | ReactProvider<any>
--   | ReactConsumer<any>;

-- deviation: alias for internal React$ flow types
type React_Node = any | { [any]: any };

export type ReactEmpty = boolean?;

-- deviation: No `Iterable` equivalent other than an array
export type ReactFragment = ReactEmpty | Array<React_Node>;

export type ReactNodeList = ReactEmpty | React_Node;

-- export type ReactText = string | number;

-- export type ReactProvider<T> = {
--   $$typeof: Symbol | number,
--   type: ReactProviderType<T>,
--   key: null | string,
--   ref: null,
--   props: {
-- 	value: T,
-- 	children?: ReactNodeList,
-- 	...
--   },
--   ...
-- };

-- export type ReactProviderType<T> = {
--   $$typeof: Symbol | number,
--   _context: ReactContext<T>,
--   ...
-- };

-- export type ReactConsumer<T> = {
--   $$typeof: Symbol | number,
--   type: ReactContext<T>,
--   key: null | string,
--   ref: null,
--   props: {
-- 	children: (value: T) => ReactNodeList,
-- 	unstable_observedBits?: number,
-- 	...
--   },
--   ...
-- };

export type ReactContext<T> = {
  -- $$typeof: Symbol | number,
  -- Consumer: ReactContext<T>,
  Consumer: any,
  -- Provider: ReactProviderType<T>,
  Provider: any,
  _calculateChangedBits: ((T, T) -> number)?,
  _currentValue: T,
  _currentValue2: T,
  _threadCount: number,
  -- DEV only
  _currentRenderer: Object?,
  _currentRenderer2: Object?,
  -- This value may be added by application code
  -- to improve DEV tooling display names
  displayName: string?,
  -- ...
  [any]: any,
};

export type ReactPortal = {
  -- $$typeof: Symbol | number,
  key: string?,
  containerInfo: any,
  children: ReactNodeList,
  -- TODO: figure out the API for cross-renderer implementation.
  implementation: any,
  -- ...
  [any]: any
};

-- export type RefObject = {|
--   current: any,
-- |};

-- deviation: No Luau support for literal types
-- export type EventPriority = 0 | 1 | 2;
export type EventPriority = number;

local exports = {}
exports.DiscreteEvent = 0
exports.UserBlockingEvent = 1
exports.ContinuousEvent = 2

-- export type ReactFundamentalComponentInstance<C, H> = {|
--   currentFiber: Object,
--   instance: mixed,
--   prevProps: null | Object,
--   props: Object,
--   impl: ReactFundamentalImpl<C, H>,
--   state: Object,
-- |};

export type ReactFundamentalImpl<C, H> = {
  displayName: string,
  reconcileChildren: boolean,
  getInitialState: nil | (Object) -> (Object),
  getInstance: (C, Object, Object) -> (H),
  getServerSideString: nil | (C, Object) -> (string),
  getServerSideStringClose: nil | (C, Object) -> (string),
  onMount: (C, any, Object, Object) -> (),
  shouldUpdate: nil | (C, Object?, Object, Object) -> (boolean),
  onUpdate: nil | (C, any, Object?, Object, Object) -> (),
  onUnmount: nil | (C, any, Object, Object) -> (),
  onHydrate: nil | (C, Object, Object) -> boolean,
  onFocus: nil | (C, Object, Object) -> boolean,
  -- ...
  [any]: any,
};

export type ReactFundamentalComponent<C, H> = {
  -- $$typeof: Symbol | number,
  [string]: any, -- FIXME (roblox): types
  impl: ReactFundamentalImpl<C, H>,
};

export type ReactScope = {
  -- $$typeof: Symbol | number,
  [string]: any, -- FIXME (roblox): types
};

-- export type ReactScopeQuery = (
--   type: string,
--   props: {[string]: mixed, ...},
--   instance: mixed,
-- ) => boolean;

-- export type ReactScopeInstance = {|
--   DO_NOT_USE_queryAllNodes(ReactScopeQuery): null | Array<Object>,
--   DO_NOT_USE_queryFirstNode(ReactScopeQuery): null | Object,
--   containsNode(Object): boolean,
--   getChildContextValues: <T>(context: ReactContext<T>) => Array<T>,
-- |};

-- Mutable source version can be anything (e.g. number, string, immutable data structure)
-- so long as it changes every time any part of the source changes.
-- ROBLOX deviation: we don't have mixed, or a type system that can represent the above
export type MutableSourceVersion = any -- $NonMaybeType<mixed>;

-- export type MutableSourceGetSnapshotFn<
--   Source: $NonMaybeType<mixed>,
--   Snapshot,
-- > = (source: Source) => Snapshot;

-- export type MutableSourceSubscribeFn<Source: $NonMaybeType<mixed>, Snapshot> = (
--   source: Source,
--   callback: (snapshot: Snapshot) => void,
-- ) => () => void;

export type MutableSourceGetVersionFn = (
  any
) -> MutableSourceVersion;

export type MutableSource<Source> = {
  _source: Source,

  _getVersion: MutableSourceGetVersionFn,

  -- Tracks the version of this source at the time it was most recently read.
  -- Used to determine if a source is safe to read from before it has been subscribed to.
  -- Version number is only used during mount,
  -- since the mechanism for determining safety after subscription is expiration time.
  --
  -- As a workaround to support multiple concurrent renderers,
  -- we categorize some renderers as primary and others as secondary.
  -- We only expect there to be two concurrent renderers at most:
  -- React Native (primary) and Fabric (secondary);
  -- React DOM (primary) and React ART (secondary).
  -- Secondary renderers store their context values on separate fields.
  -- We use the same approach for Context.
  _workInProgressVersionPrimary: nil | MutableSourceVersion,
  _workInProgressVersionSecondary: nil | MutableSourceVersion,

  -- DEV only
  -- Used to detect multiple renderers using the same mutable source.
  _currentPrimaryRenderer: Object | nil,
  _currentSecondaryRenderer: Object | nil
};

-- -- The subset of a Thenable required by things thrown by Suspense.
-- -- This doesn't require a value to be passed to either handler.
export type Wakeable = {
  then_: (() -> any, () -> any) -> (Wakeable?),
  -- Special flag to opt out of tracing interactions across a Suspense boundary.
  __reactDoNotTraceInteractions: boolean?,
  [any]: any,
};

-- deviation: This declaration uses a number of features not present in Luau's
-- type system
-- -- The subset of a Promise that React APIs rely on. This resolves a value.
-- -- This doesn't require a return value neither from the handler nor the
-- -- then function.
-- export interface Thenable<+R> {
--   then<U>(
-- 	onFulfill: (value: R) => void | Thenable<U> | U,
-- 	onReject: (error: mixed) => void | Thenable<U> | U,
--   ): void | Thenable<U>;
-- }
export type Thenable<R, U> = {
  then_: (
    (R) -> Thenable | U | nil,
    (any) -> Thenable | U | nil
  ) -> Thenable
};

return exports