import AVFoundation
import Combine
import SwiftUI
import UIKit

/// A real, opt-in camera workflow. Preview remains useful without a scene accessory.
/// No microphone input, photo output, recording, or photo-library access is configured.
struct CameraAPIDemo: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var model = CameraDemoModel()

    var body: some View {
        Group {
            #if DUO_SDK
            if #available(iOS 27.1, *) {
                NativeCameraDemo(model: model)
            } else {
                CameraDemoScreen(model: model) {
                    Text("The camera preview works here. The optional camera accessory requires iOS 27.1 or later.")
                }
            }
            #else
            CameraDemoScreen(model: model) {
                Text("The camera preview works here. Build with the iOS 27.1 SDK and DUO_SDK=1 to enable the native camera accessory.")
            }
            #endif
        }
        .navigationTitle("Camera accessory")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("apiLab.cameraScreen")
        .onDisappear { model.stop() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { model.stop() }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: AVCaptureSession.wasInterruptedNotification,
            object: model.engine.session
        ).receive(on: DispatchQueue.main)) { _ in
            model.stop(message: "Camera interrupted. Tap Start camera when it is available again.")
        }
        .onReceive(NotificationCenter.default.publisher(
            for: AVCaptureSession.runtimeErrorNotification,
            object: model.engine.session
        ).receive(on: DispatchQueue.main)) { _ in
            model.stop(message: "The camera session stopped unexpectedly. Try starting it again.")
        }
    }
}

private struct CameraDemoScreen<AccessoryControls: View>: View {
    @ObservedObject var model: CameraDemoModel
    @ViewBuilder let accessoryControls: () -> AccessoryControls
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Live camera and speaker prompt")
                    .font(.title2.bold())
                Text("Start the rear camera to preview framing. The speaker can read the same prompt on an eligible accessory display.")
                    .foregroundStyle(.secondary)

                ZStack {
                    CameraPreview(engine: model.engine)
                    if !model.isRunning {
                        Rectangle().fill(.black)
                        ContentUnavailableView(
                            "Camera is off",
                            systemImage: "camera",
                            description: Text("Tap Start camera to request access and show a live preview.")
                        )
                        .foregroundStyle(.white)
                    }
                }
                .aspectRatio(3.0 / 4.0, contentMode: .fit)
                .frame(maxWidth: 500)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(maxWidth: .infinity)
                .accessibilityLabel(model.isRunning ? "Live rear camera preview" : "Camera preview is off")
                .accessibilityIdentifier("apiLab.cameraPreview")

                Text(model.status)
                    .font(.callout)
                    .accessibilityIdentifier("apiLab.cameraStatus")

                if model.isRunning || model.isStarting {
                    Button {
                        model.stop()
                    } label: {
                        Label(model.isStarting ? "Cancel camera start" : "Stop camera", systemImage: "stop.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("apiLab.cameraStop")
                } else {
                    Button {
                        Task { await model.start() }
                    } label: {
                        Label("Start camera", systemImage: "camera")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("apiLab.cameraStart")
                }

                if model.canOpenSettings,
                   let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    Button("Open camera permission settings") { openURL(settingsURL) }
                }

                Divider()
                CameraPromptCard(model: model)
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    Text("Optional camera accessory").font(.headline)
                    accessoryControls()
                    Text("The system decides whether and where this content appears. An active camera and a foreground app are required. The main screen keeps all controls when no accessory is available.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Text("Preview only. Nothing is photographed, recorded, or saved. Leaving this screen or moving the app to the background stops the camera.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct CameraPromptCard: View {
    @ObservedObject var model: CameraDemoModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Speaker prompt", systemImage: "text.bubble")
                .font(.headline)
            Text(model.currentPrompt)
                .font(.title2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("apiLab.cameraPrompt")
            Button("Next prompt", systemImage: "arrow.right") {
                model.nextPrompt()
            }
            .buttonStyle(.bordered)
        }
    }
}

#if DUO_SDK
@available(iOS 27.1, *)
private struct NativeCameraDemo: View {
    @ObservedObject var model: CameraDemoModel
    @State private var accessoryEnabled = false
    @State private var accessoryAvailable = false
    @State private var accessoryPresented = false

    var body: some View {
        CameraDemoScreen(model: model) {
            Toggle("Show speaker prompt on accessory display", isOn: $accessoryEnabled)
                .disabled(!model.isRunning || !accessoryAvailable)
                .accessibilityIdentifier("apiLab.cameraAccessoryToggle")
            LabeledContent("System availability", value: accessoryAvailable ? "Available" : "Unavailable")
            LabeledContent("Accessory content", value: accessoryPresented ? "Presented" : "Not presented")
            if !model.isRunning {
                Text("Start the camera before enabling the accessory.")
                    .font(.footnote)
            }
        }
        .sceneAccessory {
            CameraCaptureAccessory(isEnabled: $accessoryEnabled) {
                ScrollView {
                    CameraPromptCard(model: model)
                        .padding()
                }
                .onAppear { accessoryPresented = true }
                .onDisappear { accessoryPresented = false }
            }
            .onAvailabilityChange { available in
                accessoryAvailable = available
                if !available { accessoryEnabled = false }
            }
        }
        .onChange(of: model.isRunning) { _, running in
            if !running { accessoryEnabled = false }
        }
        .onDisappear { accessoryEnabled = false }
    }
}
#endif

@MainActor
private final class CameraDemoModel: ObservableObject {
    @Published private(set) var isStarting = false
    @Published private(set) var isRunning = false
    @Published private(set) var canOpenSettings = false
    @Published private(set) var status = "Ready. Camera access is requested only after you tap Start camera."
    @Published private(set) var promptIndex = 0

    let engine = CameraDemoEngine()
    private var requestGeneration = 0
    private let prompts = [
        "One app can adapt to changing display sizes while preserving its content and state.",
        "Use local geometry and native navigation instead of assuming one fixed screen size.",
        "Keep interactive controls inside the safe area and make every feature reachable."
    ]

    var currentPrompt: String { prompts[promptIndex] }

    func nextPrompt() {
        promptIndex = (promptIndex + 1) % prompts.count
    }

    func start() async {
        guard !isStarting, !isRunning else { return }
        guard AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil else {
            status = "No rear camera is available. Use a physical device to run this preview; simulator capture is not simulated."
            return
        }

        requestGeneration += 1
        let generation = requestGeneration
        isStarting = true
        canOpenSettings = false
        status = "Checking camera permission…"

        let allowed: Bool
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            allowed = true
        case .notDetermined:
            allowed = await AVCaptureDevice.requestAccess(for: .video)
        default:
            allowed = false
        }
        // A permission dialog can outlive this screen. Never start after dismissal.
        guard generation == requestGeneration else { return }
        guard allowed else {
            isStarting = false
            let authorization = AVCaptureDevice.authorizationStatus(for: .video)
            canOpenSettings = authorization == .denied
            status = authorization == .restricted
                ? "Camera access is restricted on this device."
                : "Camera access is unavailable. Allow camera access in Settings to use the preview."
            return
        }

        status = "Starting the rear camera…"
        engine.start { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self, self.requestGeneration == generation else { return }
                self.isStarting = false
                switch result {
                case .success:
                    self.isRunning = true
                    self.status = "Live rear-camera preview. No photo or recording is being saved."
                case .failure(let error):
                    self.isRunning = false
                    self.status = error.message
                }
            }
        }
    }

    func stop(message: String = "Camera stopped. Tap Start camera to resume.") {
        requestGeneration += 1
        isStarting = false
        isRunning = false
        status = message
        engine.stop()
    }
}

private enum CameraDemoError: Error, Sendable {
    case noRearCamera
    case cannotAddInput
    case configuration(String)
    case didNotStart

    var message: String {
        switch self {
        case .noRearCamera:
            return "No rear camera is available on this device."
        case .cannotAddInput:
            return "The camera input is unavailable. Close other camera experiences and try again."
        case .configuration(let detail):
            return "Unable to configure the camera: \(detail)"
        case .didNotStart:
            return "The camera could not start. Try again when capture is available."
        }
    }
}

/// AVCaptureSession is not Sendable. This wrapper is the sole mutator: every
/// configuration/start/stop operation is serialized on `queue`. The main actor
/// only attaches the stable session reference to AVCaptureVideoPreviewLayer.
private final class CameraDemoEngine: @unchecked Sendable {
    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "com.example.AdaptiveDuoLab.camera")
    private var configured = false

    func start(completion: @escaping @Sendable (Result<Void, CameraDemoError>) -> Void) {
        queue.async { [self] in
            do {
                try configureIfNeeded()
                if !session.isRunning { session.startRunning() }
                if session.isRunning {
                    completion(.success(Void()))
                } else {
                    completion(.failure(.didNotStart))
                }
            } catch let error as CameraDemoError {
                completion(.failure(error))
            } catch {
                completion(.failure(.configuration(error.localizedDescription)))
            }
        }
    }

    func stop() {
        queue.async { [self] in
            if session.isRunning { session.stopRunning() }
        }
    }

    private func configureIfNeeded() throws {
        dispatchPrecondition(condition: .onQueue(queue))
        guard !configured else { return }
        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera, for: .video, position: .back
        ) else { throw CameraDemoError.noRearCamera }
        let input = try AVCaptureDeviceInput(device: camera)
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        if session.canSetSessionPreset(.high) { session.sessionPreset = .high }
        guard session.canAddInput(input) else { throw CameraDemoError.cannotAddInput }
        session.addInput(input)
        configured = true
    }
}

private struct CameraPreview: UIViewRepresentable {
    let engine: CameraDemoEngine

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.attach(session: engine.session)
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        uiView.updateRotation()
    }

    static func dismantleUIView(_ uiView: CameraPreviewUIView, coordinator: Void) {
        uiView.detach()
    }
}

@MainActor
private final class CameraPreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    private var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var rotationObservation: NSKeyValueObservation?

    func attach(session: AVCaptureSession) {
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.session = session
        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera, for: .video, position: .back
        ) else { return }
        let coordinator = AVCaptureDevice.RotationCoordinator(device: camera, previewLayer: previewLayer)
        rotationCoordinator = coordinator
        rotationObservation = coordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.initial, .new]) { [weak self] _, _ in
            Task { @MainActor [weak self] in self?.updateRotation() }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateRotation()
    }

    func updateRotation() {
        guard let connection = previewLayer.connection,
              let angle = rotationCoordinator?.videoRotationAngleForHorizonLevelPreview,
              connection.isVideoRotationAngleSupported(angle) else { return }
        connection.videoRotationAngle = angle
    }

    func detach() {
        rotationObservation = nil
        rotationCoordinator = nil
        previewLayer.session = nil
    }
}
