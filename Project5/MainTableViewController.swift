//
//  ViewController.swift
//  Project5
//
//  Created by Ильфат Салахов on 23.01.2023.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavController()
        fileSearch()
        checkArray()
        startGame()
    }
    
    //MARK: -Private Methods
    private func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    private func checkArray() {
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
    }
    
    private func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if isCount(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isPossible(word: lowerAnswer) {
                    if isReal(word: lowerAnswer) {
                        usedWords.insert(lowerAnswer, at: 0)
                        
                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)
                        
                        return
                    } else {
                        showAlertController(title: "Нет такого слова!", message: "Попробуй еще раз!")
                    }
                } else {
                    guard let title = title?.lowercased() else { return }
                    showAlertController(title: "Ошибка!", message: "Мы не можем собрать это слово из \(title)!")
                }
            } else {
                showAlertController(title: "Уже есть такое слово!", message: "Будь оригинальнее!")
            }
        } else {
            showAlertController(title: "Мало букв!", message: "Количество букв должно быть больше или равно трем!")
        }
    }
}

// MARK: -File Search
extension MainTableViewController {
    private func fileSearch() {
        if let startWordsURL =  Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension MainTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        cell.contentView.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }
}

// MARK: - SetupNavigationController
extension MainTableViewController {
    private func setupNavController() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshWord))
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Введите слово", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?.first?.text else { return }
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    @objc func refreshWord() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
}

// MARK: -Check Valid Word
extension MainTableViewController {
    
    private func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    private func isOriginal(word: String) -> Bool {
        guard let tempWord = title?.lowercased() else { return false }
        guard word != tempWord else { return false }
        return !usedWords.contains(word)
    }
    
    private func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word,
                                                            range: range,
                                                            startingAt: 0,
                                                            wrap: false,
                                                            language: "ru")
        return misspelledRange.location == NSNotFound
    }
    
    private func isCount(word: String) -> Bool {
        word.count >= 3 ? true : false
    }
}

// MARK: -AlertController
extension MainTableViewController {
    private func showAlertController(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

// MARK: -RestartGame
extension MainTableViewController {
}

