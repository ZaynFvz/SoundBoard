//
//  SoundViewController.swift
//  VargasSoundBoard
//
//  Created by Gonzalo Vargas on 24/05/23.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var duracionLabel: UILabel!
    
    var grabarAudio: AVAudioRecorder?
    var reproducirAudio: AVAudioPlayer?
    var audioURL: URL?
    var grabacionTimer: Timer?
    var grabacionDuracion: TimeInterval = 0
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            grabarAudio?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            grabacionTimer?.invalidate()
        } else {
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            grabacionDuracion = 0
            duracionLabel.text = formatearDuracion(grabacionDuracion)
            grabacionTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(actualizarDuracion), userInfo: nil, repeats: true)
            reproducirButton.isEnabled = false
        }
    }
    
    @objc func actualizarDuracion() {
        grabacionDuracion += 1
        duracionLabel.text = formatearDuracion(grabacionDuracion)
    }
    
    func formatearDuracion(_ duracion: TimeInterval) -> String {
        let minutos = Int(duracion) / 60
        let segundos = Int(duracion) % 60
        return String(format: "%02d:%02d", minutos, segundos)
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {
            print("Error al reproducir el audio")
        }
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.duracion = formatearDuracion(grabacionDuracion)
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
    }
    
    func configurarGrabacion() {
        do {
            // Creando sesión de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            // Creando dirección para el archivo de audio
            let basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = URL(fileURLWithPath: pathComponents.joined(separator: "/"))
            
            // Impresión de la ruta donde se guardan los archivos
            print("********************")
            print(audioURL!)
            print("********************")
            
            // Crear opciones para el grabador de audio
            var settings: [String: Any] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)
            settings[AVSampleRateKey] = 44100.0
            settings[AVNumberOfChannelsKey] = 2
            
            // Crear el objeto de grabación de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        } catch {
            print("Error al configurar la grabación de audio")
        }
    }
    
}
