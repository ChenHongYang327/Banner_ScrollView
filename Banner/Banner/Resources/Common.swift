

import UIKit

class Common {
    
    static let shard = Common()
    
    func getImage (imgIndex: Int , imgURL: String, completion: @escaping (Result<UIImage,Error>) -> Void ){
        
        // 判斷手機內是否有資料
        // sandBox - Document Path
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let savePath = documentsPath[0] + "/banner\(imgIndex).jpg"
//        print(savePath)
        
        // 有值就回傳
        if let img = UIImage(contentsOfFile: savePath) {
            
            print("ImageFromSandBox")
            completion(.success(img))

        } else {
            print("ImageFromURL")
            
            // 如手機無資料，重新抓圖並存到sandbox
            getUrlimage(urlString: imgURL) { image in
                guard let image = image else {
                    return
                }
                self.saveToSandBox(image, savePath)
                completion(.success(image))
            }
        }
    
    }
    
    private func getUrlimage (urlString: String, completion: @escaping (UIImage?) -> Void){
        let session = URLSession(configuration: .ephemeral)
        let url = URL(string: urlString)!
        let task =  session.dataTask(with: url) { data, responce, error in
            if error != nil {
                
                //  跳對話框
                completion(nil)
                
            } else {
                if let data = data {
                    let image = UIImage(data: data)
                    completion(image)
                }
            }
            
        }
        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    
    private func saveToSandBox(_ image: UIImage, _ savePath: String){
        do{
            try image.jpegData(compressionQuality: 1)?.write(to: URL(fileURLWithPath: savePath))
        } catch {
            print("Save to Sandbox Fail!")
        }
        
    }
    
}

