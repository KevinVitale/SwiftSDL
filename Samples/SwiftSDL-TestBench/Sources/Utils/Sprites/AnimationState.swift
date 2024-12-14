protocol AnimationState: Identifiable, Equatable, CaseIterable where ID == Int {
  var frameSize: Size<Float> { get }
  
  func frameDuration(for frame: Int) -> Float
  func nextFrame(after frame: Int) -> Int
  
  static var `default`: Self { get }
}
