


import UIKit
import SnapKit

class ViewController: UIViewController {

    private let screenWidth = UIScreen.main.bounds.width
    
    private var imgIndex = 0
    private var timer = Timer()
    private var dataTimer = Timer()
    private var imgs = [UIImage]()
    private var willSortImgs = [Int:UIImage]()

    
    private let indicatorView : UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
//        indicatorView.style = .large
        indicatorView.color = .systemGray
        return indicatorView
    }()
    
    private let bannerScrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let pageControll = UIPageControl()
    private func configurePageControll(){
        pageControll.pageIndicatorTintColor = .blue
        pageControll.currentPageIndicatorTintColor = .red
//        pageControll.numberOfPages = imgs.count
        pageControll.isHidden = true
    }
    
    private let progressView = UIProgressView()
    private func configureProgress (){
        progressView.progressViewStyle = .default
        progressView.setProgress(0.1, animated: true)
        progressView.progressTintColor = .blue
        progressView.trackTintColor = .red
    }
    
  
    
    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = .systemBackground
        bannerScrollView.delegate = self
        
        view.addSubview(bannerScrollView)
        view.addSubview(indicatorView)
        view.addSubview(pageControll)
        view.addSubview(progressView)

        getdata()
        
        configureProgress()
        configurePageControll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopTimer()
        stopDataTimer()
        stopIndicator()
    }
    
    // MARK: Configure VIews
    
    override func viewDidLayoutSubviews() {
        
        indicatorView.snp.makeConstraints { make in
            make.bottom.equalTo(progressView.snp.top).offset(-20)
            make.centerX.equalTo(view.snp.centerX)
        }

        progressView.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.width.equalTo(view.frame.width / 2)
            make.height.equalTo(view.frame.height / 50)
        }
        
    }
    
    private func addSubView(){
        
        pageControll.snp.makeConstraints { make in
            make.width.equalTo(screenWidth)
            make.left.equalTo(view.snp.left)
            make.height.equalTo(30)
            make.bottom.equalTo(view).offset(-30)
        }
        
        bannerScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        // 新增 3 個佔位imageView
        addImgToScrollView()

    }
    
    private func addImgToScrollView() {
        
        // add 3 img to imageView, order: last -> first -> second
        for i in 0..<3 {
            let imageView = UIImageView(frame: CGRect(x: (CGFloat(i) * screenWidth), y: 0, width: screenWidth, height: view.frame.height))

            // Img order: last -> first -> second
            imageView.image = imgs[ ((i + imgs.count - 1) % imgs.count) ]
            imageView.contentMode = .scaleToFill
            bannerScrollView.addSubview(imageView)
        }
        // set scrollView ContentSize (顯示範圍)
        bannerScrollView.contentSize = CGSize(width: screenWidth * 3, height: bannerScrollView.bounds.height)

        // 調整 scroll 位置顯示中間
        bannerScrollView.contentOffset = CGPoint(x: screenWidth, y: 0)
        
    }
    
    private func getdata(){
        
        var tmpProgressNum: Float = 0.0
        
        startIndicator()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            // 建議迴圈寫法
//            for imgUrlStr in self.imgUrls { }
            
            for (i, imgUrlStr) in self.imgUrls.enumerated() {
                Common.shard.getImage(imgIndex: i, imgURL: imgUrlStr) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let image):
                            self.imgs = self.getOrderImgs(imageIndex: i, image: image)
                            self.pageControll.numberOfPages = self.imgs.count
                            tmpProgressNum += 1.0
                            self.addProgress(progress: tmpProgressNum)
                            
                        case .failure(_):
                            return
                        }
                    }
                }
            }
            
        } //
        
    }
    
    // 重新排列網路抓到的資料
    private func getOrderImgs(imageIndex: Int, image: UIImage) -> [UIImage] {
        willSortImgs[imageIndex] = image
        
        // 重新排列（小到大）
        let sorttings = willSortImgs.sorted { firstItem, secondItem in
            return firstItem.key < secondItem.key
        }
        // 把 Dictionary 中的 value 單獨抽出來另存陣列
        var didSortImgs = [UIImage]()
        for image in sorttings {
            didSortImgs.append(image.value)
        }
        return didSortImgs
        
    }
    
    private func showBanner(){
        if imgIndex > (imgs.count - 1) {
            imgIndex = 0
        } else if imgIndex < 0 {
            imgIndex = (imgs.count - 1)
        }
        
        let currentIndex = imgIndex
        let nextIndex = (currentIndex + 1) % imgs.count
        let preIndex = (currentIndex + imgs.count - 1) % imgs.count
        
        (bannerScrollView.subviews[0] as! UIImageView).image = imgs[preIndex]
        (bannerScrollView.subviews[1] as! UIImageView).image = imgs[currentIndex]
        (bannerScrollView.subviews[2] as! UIImageView).image = imgs[nextIndex]
        
        pageControll.currentPage = currentIndex
        
    }


    // MARK: test Data

    private let imgUrls = [
            "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource124/v4/13/e8/7a/13e87a36-e57b-05c0-4851-48f9f6d55be6/deaebc5f-5bf5-46e6-8726-074946d73c2d_1.png/392x696bb.png",
            "https://is2-ssl.mzstatic.com/image/thumb/PurpleSource124/v4/5d/a3/2c/5da32cc0-3c87-c379-2538-0e8f20ecdfee/3cf79572-bb90-4c0c-8fe7-92264e6e2b75_4.png/392x696bb.png",
            "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource124/v4/65/7c/a5/657ca590-1297-c3ab-e0d2-c28256a3b3c9/bed37329-866e-4c43-8b07-f8b41e192d4e_7.png/392x696bb.png",
            "https://is3-ssl.mzstatic.com/image/thumb/PurpleSource124/v4/68/84/68/688468c2-4409-951b-488d-1e930454f59d/15a7c338-51dd-43e9-930c-3264db10796d_8.png/392x696bb.png",
            "https://is4-ssl.mzstatic.com/image/thumb/PurpleSource124/v4/20/2f/70/202f7048-de1b-cf91-77c3-8f05df715e99/cc7b1d76-b4aa-4fd5-8c77-301eb086aefa_9.png/392x696bb.png",
            "https://is5-ssl.mzstatic.com/image/thumb/PurpleSource124/v4/3a/0e/b2/3a0eb27c-5718-b5f2-f3d9-d4d8b3021b3e/8fde62ec-63ed-4acb-9b13-162a2e416a00_10.png/392x696bb.png",
            "https://is5-ssl.mzstatic.com/image/thumb/PurpleSource124/v4/61/2c/40/612c40c2-12b8-b57f-5566-c291431a8840/68033fa9-52d1-4288-b492-d0e61c258fdc_11.png/392x696bb.png",
            "https://is2-ssl.mzstatic.com/image/thumb/PurpleSource124/v4/a7/7b/a1/a77ba13c-dc94-af8c-5a7a-88282409ed0c/5a83e8df-3496-4241-8f05-246997c16c26_12.png/392x696bb.png",
            "https://is4-ssl.mzstatic.com/image/thumb/PurpleSource124/v4/12/2d/15/122d151c-50b3-cd7a-c308-59806646923a/88302ad4-0bd2-4dba-a959-2683c52ce319_14.png/392x696bb.png",
            "https://is5-ssl.mzstatic.com/image/thumb/PurpleSource114/v4/05/e4/ce/05e4ceeb-3a28-29e2-ff6e-0c580939c900/97a772dc-e778-418a-a4c8-7d9b275662de_13.png/392x696bb.png"
        ]
 
}

// scrollView delegate
extension ViewController: UIScrollViewDelegate {
        
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        // 螢幕左邊滑到底，偏移到中間view
        if scrollView.contentOffset.x == 0 {
            bannerScrollView.contentOffset = CGPoint(x: screenWidth, y: 0)
            imgIndex -= 1
            showBanner()

        }
        
        // 螢幕右邊滑到底，偏移到中間view
        if scrollView.contentOffset.x == screenWidth * 2 {
            bannerScrollView.contentOffset = CGPoint(x: screenWidth, y: 0)
            imgIndex += 1
            showBanner()

        }
        startTimer()
    }
    
}

// Tool
extension ViewController {
    
    private func startTimer(){
        stopDataTimer()
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(nextItem), userInfo: nil, repeats: true)
    }
    
    private func stopTimer(){
        timer.invalidate()
    }
    
    private func startDataTimer(){
        stopDataTimer()
        dataTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(showTimeOutDialog), userInfo: nil, repeats: false)
    }
    
    private func stopDataTimer(){
        dataTimer.invalidate()
    }
    
    private func startIndicator(){
        indicatorView.isHidden = false
        indicatorView.startAnimating()
    }
    
    private func stopIndicator(){
        indicatorView.isHidden = true
        indicatorView.stopAnimating()
    }
    
    @objc private func nextItem(){
        imgIndex += 1
        showBanner()
    }
    
    private func addProgress(progress: Float){
        
        stopDataTimer()

        let totalCount = Float(imgUrls.count)
        let itemProgress = progress / totalCount
        progressView.progress = itemProgress
        
        if itemProgress == 1.0 {
//            print("-----start-----")
            
            progressView.isHidden = true
            pageControll.isHidden = false
            
            addSubView()
            stopIndicator()
            startTimer()
          
        } else {
            startDataTimer()
        }
    }
        
    
    @objc private func showTimeOutDialog(){
        
        let alertControll = UIAlertController(title: "抓取資料時間過長", message: "是否需要重新抓取", preferredStyle: .alert)
        alertControll.addAction(UIAlertAction(title: "是",
                                              style: .default,
                                              handler: { alertAction in
            self.stopDataTimer()
            self.stopTimer()
            self.startIndicator()
            self.progressView.isHidden = false
            self.progressView.progress = 0.1
            
            self.getdata()
            
        }))
        alertControll.addAction(UIAlertAction(title: "否",
                                              style: .cancel,
                                              handler: { alertAction in
            self.startDataTimer()
        }))
        
        present(alertControll, animated: true, completion: nil)
        
    }
        
}


