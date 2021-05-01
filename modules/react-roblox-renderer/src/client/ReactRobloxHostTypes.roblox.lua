local Workspace = script.Parent.Parent.Parent

local ReactInternalTypes = require(Workspace.ReactReconciler.ReactInternalTypes)
type Fiber = ReactInternalTypes.Fiber;
type FiberRoot = ReactInternalTypes.FiberRoot;
local ReactTypes = require(Workspace.Shared.ReactTypes)
type MutableSource<T> = ReactTypes.MutableSource<T>;
type ReactNodeList = ReactTypes.ReactNodeList;

type Array<T> = { [number]: T };

-- deviation: Containers should also be instances; at some point, we may
-- restrict which _kinds_ of instances, but that's not necessary right now
export type Container = Instance;
-- export type Container =
--   | (Element & {_reactRootContainer?: RootType, ...})
--   | (Document & {_reactRootContainer?: RootType, ...})

-- deviation: We can't export this as `Instance`; luau gets upset!
export type HostInstance = Instance;

-- export type TextInstance = Text;

-- ROBLOX TODO: Revisit this type for suspense
-- export type SuspenseInstance = Comment & {_reactRetry?: () => void, ...}
export type SuspenseInstance = any

export type Type = string;
export type Props = {
  autoFocus: boolean?,
  children: any,
  disabled: boolean?,
  hidden: boolean?,
  suppressHydrationWarning: boolean?,
  dangerouslySetInnerHTML: any,
  style: { display: string, [any]: any }?,
  bottom: number?,
  left: number?,
  right: number?,
  top: number?,
  -- ...
  [any]: any,
};

-- ROBLOX TODO: Revisit this type for hydration
-- export type HydratableInstance = Instance | TextInstance | SuspenseInstance
export type HydratableInstance = Instance | SuspenseInstance

-- ROBLOX TODO: Revisit this to make sure it makes sense
-- export type PublicInstance = Element | Text
export type PublicInstance = HostInstance

-- ROBLOX TODO: See if these actually make sense
type HostContextDev = {
  namespace: string,
  ancestorInfo: any,
  -- ...
  [any]: any,
}
type HostContextProd = string
export type HostContext = HostContextDev | HostContextProd

export type RootType = {
  render: (ReactNodeList) -> (),
  unmount: () -> (),
  _internalRoot: FiberRoot,
  -- ...
  [any]: any,
};

export type RootOptions = {
  hydrate: boolean?,
  hydrationOptions: {
    onHydrated: (any) -> ()?,
    onDeleted: (any) -> ()?,
    mutableSources: Array<MutableSource<any>>?,
    -- ...
    [any]: any,
  }?,
  -- ...
  [any]: any,
};

return {}