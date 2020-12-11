import UIKit

class AnimeAddView: UITableViewController {
    @IBOutlet private var titleField: UITextField!
    @IBOutlet private var episodeField: UITextField!
    @IBOutlet private var image: UIImageView!
    @IBOutlet private var segmentedControl: UISegmentedControl!
    var editAnime: Anime?

    let manager = AnimeManager.shared
    let imagePicker: ImagePickerView = {
        let pickerController = ImagePickerView()
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        return pickerController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let anime = editAnime {
            navigationItem.rightBarButtonItems?.removeFirst()
            navigationItem.title = Constants.Strings.edit.locale
            titleField.text = anime.title
            episodeField.text = String(anime.episode)
            segmentedControl.selectedSegmentIndex = anime.category
            image.image = anime.cover?.img() ?? UIImage(named: Constants.Images.default.rawValue)
        }

        if #available(iOS 13, *) {
            segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.label], for: .normal)
        } else {
            segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        }
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemOrange], for: .selected)

        imagePicker.delegate = self
        if #available(iOS 13, *) {} else {
            tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: -38, right: 0)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.tintColor = .systemOrange
        navigationController?.navigationBar.tintColor = .systemOrange
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.tintColor = .systemPurple
        navigationController?.navigationBar.tintColor = .systemPurple
    }

    @IBAction private func save2() {
        save(true)
    }

    @IBAction private func save(_ keepOpen: Bool = false) {
        self.view.endEditing(true)

        let img = image.image == UIImage(named: Constants.Images.default.rawValue) ? nil : Cover(image: image!.image)
        let ep = Int(episodeField.text.trim()) ?? 1
        var temp = Anime(id: editAnime != nil ? editAnime!.id : UUID(),
                         title: titleField.text.trim(),
                         cover: img,
                         category: segmentedControl.selectedSegmentIndex,
                         episode: ep)

        if let tempImg = image.image, tempImg != UIImage(named: Constants.Images.default.rawValue), let color = tempImg.averageColor {
            temp.coverColor = CoverColor(color: color)
        }

        try? manager.store.save(temp)
        UserDefaults.standard.set(true, forKey: Constants.Keys.animeReload.rawValue)

         if keepOpen {
            AlertManager.shared.savedInfo(self, Constants.Strings.anime.locale)
         } else {
             self.navigationController?.popToRootViewController(animated: true)
         }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            AlertManager.shared.selectImage(self) { index in
                switch index {
                case 0:
                    AlertManager.shared.manualImageSearchAnime(self) { text in
                        self.image.image = WebImage.apiImage(text, "anime")
                    }
                case 1:
                    self.imagePicker.sourceType = .photoLibrary
                    self.present(self.imagePicker, animated: true)
                case 2:
                    self.imagePicker.sourceType = .camera
                    self.present(self.imagePicker, animated: true)
                default:
                    self.image.image = UIImage(named: Constants.Images.default.rawValue)
                }
            }
        }
    }
}

extension AnimeAddView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.image.image = UIImage(named: Constants.Images.default.rawValue)
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage, let cg = image.cgImage {
            if image.imageOrientation == .up {
                self.image.image = UIImage(cgImage: cg, scale: 1.0, orientation: .left)
            } else if image.imageOrientation == .down {
                self.image.image = UIImage(cgImage: cg, scale: 1.0, orientation: .right)
            } else {
                self.image.image = image
            }
        }
        picker.dismiss(animated: true)
    }
}
