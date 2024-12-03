import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var isFlashing: Bool = false
    
    let morseCodeMap: [Character: String] = [
        "a": ".-", "b": "-...", "c": "-.-.", "d": "-..", "e": ".",
        "f": "..-.", "g": "--.", "h": "....", "i": "..", "j": ".---",
        "k": "-.-", "l": ".-..", "m": "--", "n": "-.", "o": "---",
        "p": ".--.", "q": "--.-", "r": ".-.", "s": "...", "t": "-",
        "u": "..-", "v": "...-", "w": ".--", "x": "-..-", "y": "-.--",
        "z": "--..", "1": ".----", "2": "..---", "3": "...--",
        "4": "....-", "5": ".....", "6": "-....", "7": "--...",
        "8": "---..", "9": "----.", "0": "-----", " ": "/"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Введите текст для кодирования", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                if !isFlashing {
                    let morseCode = encodeToMorse(inputText.lowercased())
                    flashMorseCode(morseCode)
                }
            }) {
                Text(isFlashing ? "Передача..." : "Отправить через вспышку")
                    .padding()
                    .background(isFlashing ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isFlashing)
        }
        .padding()
    }
    
    func encodeToMorse(_ text: String) -> String {
        text.compactMap { morseCodeMap[$0] }.joined(separator: " ")
    }
    
    func flashMorseCode(_ morseCode: String) {
        isFlashing = true
        DispatchQueue.global().async {
            for symbol in morseCode {
                guard isFlashing else { break }
                
                switch symbol {
                case ".":
                    flash(duration: 0.2)
                case "-":
                    flash(duration: 0.6)
                case " ":
                    Thread.sleep(forTimeInterval: 0.2)
                case "/":
                    Thread.sleep(forTimeInterval: 0.8)
                default:
                    break
                }
                Thread.sleep(forTimeInterval: 0.2)
            }
            isFlashing = false
        }
    }
    
    func flash(duration: TimeInterval) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            try device.setTorchModeOn(level: 1.0)
            Thread.sleep(forTimeInterval: duration)
            device.torchMode = .off
            device.unlockForConfiguration()
        } catch {
            print("Ошибка: \(error)")
        }
    }
}


