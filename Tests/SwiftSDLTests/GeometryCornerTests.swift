import Testing
import SwiftSDL

/// Corner accessors must offset by the rect's origin.
///
/// Every assertion deliberately uses a non-origin rect: origin-anchored rects
/// were exactly the coincidence that masked the original bug (the Sprite test
/// bench rendered "correctly" only because its rects start at 0,0).
///
/// Pure math — no SDL runtime needed, safe to run in parallel.
@Suite struct RectCornerTests {
  @Test func sdlRectCorners() {
    let rect = SDL_Rect(x: 10, y: 20, w: 30, h: 40)
    #expect(rect.topLeft     == SDL_Point(x: 10, y: 20))
    #expect(rect.topRight    == SDL_Point(x: 40, y: 20))
    #expect(rect.bottomLeft  == SDL_Point(x: 10, y: 60))
    #expect(rect.bottomRight == SDL_Point(x: 40, y: 60))
  }

  @Test func sdlFRectCorners() {
    let rect = SDL_FRect(x: 10, y: 20, w: 30, h: 40)
    #expect(rect.topLeft     == SDL_FPoint(x: 10, y: 20))
    #expect(rect.topRight    == SDL_FPoint(x: 40, y: 20))
    #expect(rect.bottomLeft  == SDL_FPoint(x: 10, y: 60))
    #expect(rect.bottomRight == SDL_FPoint(x: 40, y: 60))
  }

  @Test func simd4RectCorners() {
    let rect: Rect<Int32> = [10, 20, 30, 40]  // x, y, w, h
    #expect(rect.topLeft     == Point<Int32>(10, 20))
    #expect(rect.topRight    == Point<Int32>(40, 20))
    #expect(rect.bottomLeft  == Point<Int32>(10, 60))
    #expect(rect.bottomRight == Point<Int32>(40, 60))
  }
}
