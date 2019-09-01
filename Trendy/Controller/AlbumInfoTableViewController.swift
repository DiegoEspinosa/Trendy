//
//  AlbumInfoTableViewController.swift
//  Trendy
//
//  Created by Diego Espinosa on 8/29/19.
//  Copyright © 2019 Diego Espinosa. All rights reserved.
//

import UIKit

class AlbumInfoTableViewController: UITableViewController {
    
    var album : Album?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Int(tableView.frame.width), height: 250))
        
        let imageView = UIImageView.init(frame: CGRect.init(x: (header.frame.width / 2) - 75, y: 20, width: 150 , height: 150))
        imageView.downloaded(from: (album?.albumImageUrl)!)
        
        let title = createAlbumTitleLabel(header: header)
        
        header.addSubview(imageView)
        header.addSubview(title)
        
        header.clipsToBounds = true
        return header
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(250)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumInfoCell", for: indexPath)

        // Configure the cell...

        return cell
    }
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Private Functions
    private func createAlbumTitleLabel(header: UIView) -> UILabel {
        let title = UILabel()
        title.frame = CGRect.init(x: 0, y: 180, width: header.frame.width, height: 25)
        title.text = album?.albumTitle
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = UIColor.black
        title.textAlignment = .center
        return title
    }

}
