import Foundation
import AVFoundation
import Speech

protocol SpeechRecognizerServiceDelegate: AnyObject {
    
    func speechRecognizerDidReceive(transcription: String)
    func speechRecognizerDidStartListening()
    func speechRecognizerDidStopListening()
}

final class SpeechRecognizerService {
    
    // MARK: - Internal Properties
    
    weak var delegate: SpeechRecognizerServiceDelegate?
    
    // MARK: - Private Properties
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private(set) var isRecording = false
    
    // MARK: - Internal Methods
    
    func toggleRecording() {
        isRecording ? stopRecording() : requestSpeechAuthorizationAndStart()
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        delegate?.speechRecognizerDidStopListening()
    }
    
    // MARK: - Private Methods
    
    private func requestSpeechAuthorizationAndStart() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard let self, status == .authorized else { return }
            DispatchQueue.main.async {
                self.startRecording()
                self.delegate?.speechRecognizerDidStartListening()
            }
        }
    }
    
    private func startRecording() {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        
        guard let recognitionRequest else { return }
        let inputNode = audioEngine.inputNode
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }
            if let result, self.isRecording {
                let transcribed = result.bestTranscription.formattedString
                self.delegate?.speechRecognizerDidReceive(transcription: transcribed)
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stopRecording()
            }
        }
        
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        isRecording = true
    }
}

