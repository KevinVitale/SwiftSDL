#if canImport(CSDL3)
@_exported import CSDL3
#endif

#if canImport(Collections)
@_exported import Collections
#endif

public protocol SDL_Flag:
  RawRepresentable,
  CaseIterable,
  CustomDebugStringConvertible,
  OptionSet
where RawValue: FixedWidthInteger
{ }

public enum Flags { }

@_exported import class Foundation.NotificationCenter
@_exported import struct Foundation.Notification
@_exported import struct Foundation.Measurement
@_exported import class Foundation.UnitDuration
@_exported import class Foundation.UnitAngle
@_exported import struct Foundation.UUID
