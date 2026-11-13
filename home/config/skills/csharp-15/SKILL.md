---
name: csharp-15
description: Use the new C# 15 (.NET 11) language features - collection expression arguments `with(...)`, union types, closed hierarchies, extension indexers, labeled break/continue, static interface members on older runtimes, and the memory-safety preview. Use when writing or reviewing C# targeting net11.0, or when modernizing C# code.
---

# C# 15 features

Source: https://learn.microsoft.com/en-us/dotnet/csharp/whats-new/csharp-15

C# 15 is the default language version for `net11.0` with the .NET 11 SDK
(still prerelease at time of writing). Everything except memory safety works
without `<LangVersion>preview</LangVersion>`. If the SDK is older, features
will fail to compile: check `dotnet --version` first.

```xml
<PropertyGroup>
  <TargetFramework>net11.0</TargetFramework>
  <!-- only for the memory-safety preview: -->
  <LangVersion>preview</LangVersion>
</PropertyGroup>
```

## Collection expression arguments

Put `with(...)` as the **first** element to pass constructor/factory args.

```csharp
List<string> names = [with(capacity: values.Length * 2), .. values];
HashSet<string> set = [with(StringComparer.OrdinalIgnoreCase), "Hello", "HELLO"]; // 1 element
```

Use for capacity, comparers, etc. instead of building then copying.

## Union types

`union` declares a value that is exactly one of several case types. Implicit
conversions from each case; switches are exhaustive without a discard arm.

```csharp
public record class Cat(string Name);
public record class Dog(string Name);
public union Pet(Cat, Dog);

Pet pet = new Dog("Rex");
string name = pet switch { Dog d => d.Name, Cat c => c.Name };
```

Prefer over `object` or marker-interface hierarchies for closed result/variant
types (e.g. `union Result(Success, Failure)`). Don't add `_ =>` arms; it hides
missing-case warnings when cases are added.

## Closed hierarchies

`closed` class: only derivable in its declaring assembly, so direct
descendants are known and switches are exhaustive.

```csharp
public closed record class GateState;
public record class Closed : GateState;
public record class Open(float Percent) : GateState;

string Describe(GateState s) => s switch
{
    Closed => "closed",
    Open(var p) => $"{p}% open",
};
```

Notes:
- `closed` is contextual and implies `abstract`; can't combine with `sealed`, `static`, or `abstract`.
- Not transitive: mark intermediate descendants `closed` too for deeper exhaustiveness.
- Use `closed` when the case set is a class hierarchy (shared state/behavior); `union` when cases are unrelated types.

## Extension indexers

Indexers in `extension` blocks. The receiver **must be named** (indexers are instance members).

```csharp
public static class SequenceIndexer
{
    extension(IEnumerable<int> sequence)
    {
        public int this[int index] => sequence.ElementAt(index);
    }
}
var third = Enumerable.Range(1, 10)[2];
```

## Labeled break / continue

Label goes directly on the loop or `switch`. Replaces bool flags and `goto`
in nested loops (analyzer IDE0410 flags the old patterns).

```csharp
outer: for (int r = 0; r < grid.Height; r++)
{
    for (int c = 0; c < grid.Width; c++)
    {
        if (grid[r, c].IsBlocked) continue outer;
        if (grid[r, c].IsGoal) break outer;
    }
}
```

Unlabeled `break`/`continue` are unchanged (innermost target).

## Static interface members on older runtimes

Non-virtual static interface members (helpers) now work even on runtimes
without default-interface-implementation support (e.g. netstandard2.0 / .NET Framework targets).

```csharp
public interface IMeasurement
{
    public static double ToMeters(double cm) => cm / 100;
}
IMeasurement.ToMeters(250);
```

Still needs runtime support: instance default implementations,
`static abstract`/`static virtual`, protected interface members.

## Memory safety (preview)

Requires `<LangVersion>preview</LangVersion>` and `AllowUnsafeBlocks`.
Updated rules additionally need the `updated-memory-safety-rules` compiler
feature flag (see the language-options docs for project / file-based syntax).

Without an `unsafe` context you may now: declare pointer types and use `&`,
use `fixed`, convert `stackalloc` to a pointer, and use `sizeof` on unmanaged types.
Still requires `unsafe`: `*p`, `p->m`, `p[i]`, function pointer invocation.

`unsafe(expr)` makes a single expression unsafe (field initializers,
constructor initializers, `catch` filters):

```csharp
static readonly int Signature = unsafe(ReadSignature());
```

With updated rules, `unsafe` on a member means *requires-unsafe*: callers must
be in an unsafe context. New contextual keyword `safe` marks `extern` members
and fields in explicit/extended-layout types as safe. Treat as experimental;
don't use in shared libraries without asking.

## Runtime async (.NET 11 runtime feature, not a C# syntax change)

Source: https://learn.microsoft.com/en-us/dotnet/core/whats-new/dotnet-11/runtime

Runtime-native async (Runtime Async V2) replaces compiler-generated async
state machines with runtime-managed suspension. It is a **preview, opt-in**
feature: NOT enabled by default for user code. (The .NET libraries
themselves are built with it.) No source changes needed; `async`/`await` stay the same.

```xml
<PropertyGroup>
  <Features>runtime-async=on</Features>
</PropertyGroup>
```

- `net11.0` projects don't need `EnablePreviewFeatures`.
- The `DOTNET_RuntimeAsync` / `UNSUPPORTED_RuntimeAsync` env vars were removed.
- Docs mention `<UseRuntimeAsync>false</UseRuntimeAsync>` to opt out per project.
- Benefits: cleaner live stack traces (profilers, debugger, `new StackTrace()`),
  lower overhead, works with NativeAOT and ReadyToRun.
- Exception stack traces look the same either way.
- Don't enable in shared/production projects without asking; report perf/size findings upstream.

## Guidance

- Don't rewrite existing code to use these unless asked or clearly beneficial.
- Check the project's `TargetFramework` before using any of this.
- Report compiler problems at https://github.com/dotnet/roslyn/issues.
