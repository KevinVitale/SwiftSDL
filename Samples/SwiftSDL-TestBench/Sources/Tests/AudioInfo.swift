extension SDL.Test {
  final class AudioInfo: AsyncParsableCommand {
    private enum CodingKeys: String, CodingKey {
      case options
    }
    
    static let configuration = CommandConfiguration(
      abstract: "Simple program to test the SDL audio information routines"
    )
    
    @OptionGroup var options: Options
    
    static let name: String = "SDL Test: Audio Test"
    
    func run() async throws {
      try SDL_Init(.audio)
      
      guard case(.success(let audioDrivers)) = AudioDriver.available, audioDrivers.count > 0 else {
        print("No build-in audio drivers")
        return
      }
      
      for (idx, driver) in audioDrivers.enumerated() {
        print("  \(idx): \(driver)")
      }
      
      print("Using audio driver: \(AudioDriver.current!)")
      
      if let playbackDevices = try? AudioDevices.available(for: .playback).get() {
        print("Found \(playbackDevices.count) playback device\(playbackDevices.count > 0 ? "s" : "")")
        for (idx, playbackDevice) in playbackDevices.enumerated() {
          _printDeviceInfo(playbackDevice, idx)
        }
      }
      else {
        print("No playback devices found")
      }
      
      if let recordingDevices = try? AudioDevices.available(for: .recording).get() {
        print("Found \(recordingDevices.count) recording device\(recordingDevices.count > 0 ? "s" : "")")
        for (idx, recordingDevice) in recordingDevices.enumerated() {
          _printDeviceInfo(recordingDevice, idx)
        }
      }
      else {
        print("No playback recording found")
      }
      
      print("Default playback device:")
      _printDeviceInfo(.defaultPlayback)
      
      print("Default recording device:")
      _printDeviceInfo(.defaultRecording)

      SDL_Quit()
    }
    
    private func _printDeviceInfo(_ device: AudioDeviceID, _ idx: Int? = nil) {
      do {
        if let idx = idx {
          print("  \(idx): \(try device.name.get())")
          let format = try device.spec.get()
          let spec = format.0
          let frames = format.bufferSize
          print("     Sample Rate: \(spec.freq)")
          print("     Channels: \(spec.channels)")
          print("     SDL_AudioFormat: \(String(spec.format.rawValue, radix: 16))")
          print("     Buffer Size: \(frames) frames")
        } else {
          let defaultRecording = AudioDeviceID.defaultRecording
          print("\(try defaultRecording.name.get())")
          let format = try defaultRecording.spec.get()
          let spec = format.0
          let frames = format.bufferSize
          print("Sample Rate: \(spec.freq)")
          print("Channels: \(spec.channels)")
          print("SDL_AudioFormat: \(String(spec.format.rawValue, radix: 16))")
          print("Buffer Size: \(frames) frames")
        }
      } catch {
        print("  \(error)")
      }
    }
  }
}
