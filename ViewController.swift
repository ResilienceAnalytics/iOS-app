import UIKit

class ViewController: UIViewController {

    // Outlets for submit transaction section
    @IBOutlet weak var transactionAmount: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var participant1: UITextField!
    @IBOutlet weak var participant2: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    // Outlets for receive transaction section
    @IBOutlet weak var receivePassword: UITextField!
    @IBOutlet weak var receiveParticipant1: UITextField!
    @IBOutlet weak var receiveParticipant2: UITextField!
    @IBOutlet weak var receiveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up button actions
        submitButton.addTarget(self, action: #selector(submitTransaction), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(receiveTransaction), for: .touchUpInside)
    }
    
    @objc func submitTransaction() {
        guard let amount = transactionAmount.text,
              let password = self.password.text,
              let participant1 = participant1.text,
              let participant2 = participant2.text,
              !amount.isEmpty, !password.isEmpty, !participant1.isEmpty, !participant2.isEmpty else {
            showAlert(message: "Please fill all fields")
            return
        }
        
        let transactionAmount = Int(amount) ?? 0
        let participants = [participant1, participant2]
        
        let json: [String: Any] = [
            "transaction_amount": transactionAmount,
            "password": password,
            "participants": participants
        ]
        
        guard let url = URL(string: "http://your_server_address/submit_transaction") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = jsonData
        } catch {
            print("Failed to serialize JSON")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(message: "Request failed: \(error.localizedDescription)")
                }
                return
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        self.showAlert(message: "Transaction submitted successfully")
                    } else {
                        self.showAlert(message: "Error: \(responseString)")
                    }
                }
            }
        }
        
        task.resume()
    }
    
    @objc func receiveTransaction() {
        guard let password = receivePassword.text,
              let participant1 = receiveParticipant1.text,
              let participant2 = receiveParticipant2.text,
              !password.isEmpty, !participant1.isEmpty, !participant2.isEmpty else {
            showAlert(message: "Please fill all fields")
            return
        }
        
        let participants = [participant1, participant2]
        
        let json: [String: Any] = [
            "password": password,
            "participants": participants
        ]
        
        guard let url = URL(string: "http://your_server_address/receive_transaction") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            request.httpBody = jsonData
        } catch {
            print("Failed to serialize JSON")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(message: "Request failed: \(error.localizedDescription)")
                }
                return
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        self.showAlert(message: "Transaction received successfully")
                    } else {
                        self.showAlert(message: "Error: \(responseString)")
                    }
                }
            }
        }
        
        task.resume()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
